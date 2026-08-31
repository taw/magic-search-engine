require "csv"

# MTGO catalog ids: the client's own catalog where we can match it onto one of
# our printings, mtgjson's where we can't.
#
# The client is the authority on ids. They are exactly what a .dek file asks
# for, they are assigned once and never move, and everything MTGO has is in
# there. What it has no notion of is our set codes or our collector numbers, so
# every row has to be matched onto a printing: the set code is MTGO's own, the
# number is "270/269" or "a410" or blank, the name is the printed one, and a
# multi-face card is several rows of which only the CARD one is the whole card.
#
# It is not the authority on what MTGO sells. Its catalog was seeded with the
# whole of paper Magic in release order, so it has objects for sets MTGO never
# put online, and a printing our data says is paper only must not come out of
# here with an id.
#
# mtgjson's ids come already attached to a printing, but they drift - on a
# multi-face card it keeps changing which face's id it reports - so they are
# only used where the match fails.
class PatchMtgoIds < Patch
  # Only CARD rows are cards a deck can name. SUBC is one face of a card the
  # client also lists as a CARD, TOKN is a token, PLAD a helper card.
  CARD_TYPE = "CARD"

  # How well an id is attested, best first. Two printings that both want one
  # id are resolved in this order, so a guess never displaces a match.
  BY_NUMBER = 0   # the client's number for it is one of ours
  BY_NAME = 1     # one row, one card of ours, one name
  BY_MTGJSON = 2  # several rows, and the client has the one mtgjson picked
  FROM_MTGJSON = 3 # no row at all, so mtgjson's word for it

  def call
    build_name_index
    @fallbacks = Hash.new{|hash, set_code| hash[set_code] = [] }
    @paper_only = Hash.new(0)
    @paper_only_ids = Set[]
    @contested = Hash.new(0)
    @matched = Set[]
    @matched_printings = 0

    assign(proposals)
    report
  end

  private

  def csv_path
    Indexer::ROOT + "mtgo_ids.csv"
  end

  # [rank, card, id] for every printing we have an id for at all
  def proposals
    result = []
    each_printing do |card|
      rank, row = client_row(card)
      id = row ? row[:id] : mtgjson_id(card)
      next unless id
      # MTGO having an object is not MTGO selling the card
      if !card["mtgo"]
        if row
          @paper_only[card["set_code"]] += 1
          @paper_only_ids << row[:id]
        end
        next
      end
      result << [rank || FROM_MTGJSON, card, id]
    end
    result
  end

  # One id belongs to one card, however many faces that card has. Anything
  # else means we matched two of our printings onto one MTGO object, so the
  # worse attested of the two gets nothing rather than something wrong.
  def assign(proposals)
    owners = {}
    proposals.each_with_index.sort_by{|(rank, _, _), order| [rank, order] }.each do |(rank, card, id), _|
      card_key = [card["set_code"], base_number(card)]
      if owners.fetch(id, card_key) != card_key
        @contested[card["set_code"]] += 1
        next
      end
      owners[id] = card_key
      card["mtgo_id"] = id
      if rank == FROM_MTGJSON
        @fallbacks[card["set_code"]] << card
      else
        @matched << id
        @matched_printings += 1
      end
    end
  end

  # One row per printing in the client's catalog, in the client's own terms
  def client_rows
    @client_rows ||= CSV.read(csv_path, headers: true)
      .select{|row| row["Type"] == CARD_TYPE}
      .map{|row| {
        id: row["Id"],
        mtgo_set: row["Set"],
        name: normalize_name(row["Name"]),
        printed_name: row["Name"],
        number: normalize_number(row["Number"]),
      }}
  end

  # {our set code => {name => [row, ...]}}. An MTGO set that holds cards from
  # several sets of ours offers its rows to each of them, and the one card one
  # id rule sorts out anything that two of them both want.
  def client_index
    @client_index ||= begin
      index = {}
      client_rows.each do |row|
        our_set_codes.fetch(row[:mtgo_set], []).each do |set_code|
          ((index[set_code] ||= {})[row[:name]] ||= []) << row
        end
      end
      index
    end
  end

  # {MTGO set code => [our set code, ...]}, most of them one to one. mtgjson
  # knows MTGO's set codes and only disagrees with our own for sets MTGO
  # renamed; mtgo_set_codes.txt covers what it and mci get wrong, and the MTGO
  # sets that are more than one set to us.
  def our_set_codes
    @our_set_codes ||= begin
      codes = mtgo_set_codes.dup
      known_set_codes.each{|code, ours| codes[code] ||= ours }
      guessed_set_codes(codes).each{|code, ours| codes[code] ||= ours }
      codes
    end
  end

  def mtgo_set_codes
    @mtgo_set_codes ||= begin
      codes = (Indexer::ROOT + "mtgo_set_codes.txt")
        .readlines
        .map{|line| line.sub(/#.*/, "").split }
        .reject(&:empty?)
        .to_h{|code, *set_codes| [code.upcase, set_codes] }
      warn_about_unknown_sets(codes)
      codes
    end
  end

  def known_set_codes
    codes = {}
    each_set do |set|
      codes[set["code"].upcase] = [set["code"]]
    end
    # An MTGO code wins over a set of ours that happens to share it,
    # e.g. MTGO's EVG is Elves vs Goblins, which we call dd1
    each_set do |set|
      codes[set["mtgo_code"].upcase] = [set["code"]] if set["mtgo_code"]
    end
    codes
  end

  # magiccards.info took a lot of its codes from MTGO, so alternative_code
  # covers sets mtgjson has no mtgoCode for - but it is its own namespace, not
  # MTGO's, and where the two disagree it disagrees silently. Its `le` is
  # Legions where MTGO's LE is Legends, its `al` is Alpha where MTGO's AL is
  # Alliances. So it only gets a say where nothing else does: the client code
  # is otherwise unclaimed, and that set of ours has no client set already.
  def guessed_set_codes(known)
    already_matched = client_rows.flat_map{|row| known[row[:mtgo_set]].to_a }.to_set
    by_mtgo_set = client_rows.group_by{|row| row[:mtgo_set] }
    codes = {}
    each_set do |set|
      code = set["alternative_code"] or next
      next if known.has_key?(code.upcase) or already_matched.include?(set["code"])
      rows = by_mtgo_set[code.upcase] or next
      next unless same_set?(rows, set["code"])
      codes[code.upcase] = [set["code"]]
    end
    codes
  end

  # Sets get deleted and renamed, and a mapping to one we no longer have is
  # silently no mapping at all
  def warn_about_unknown_sets(codes)
    ours = Set[]
    each_set{|set| ours << set["code"] }
    unknown = codes.values.flatten.uniq.reject{|set_code| ours.include?(set_code) }
    warn "mtgo_set_codes.txt names sets we do not have: #{unknown.join(", ")}" unless unknown.empty?
  end

  # mci's `al` is Alpha where MTGO's AL is Alliances, and the two have no card
  # in common - which, with no third source to ask, is the whole of how we can
  # tell a shared code from the same set
  def same_set?(rows, set_code)
    ours = @cards_by_name[set_code] or return false
    rows.count{|row| ours.has_key?(row[:name]) } * 2 > rows.size
  end

  # [rank, row], or nil if nothing in the client is about this printing
  def client_row(card)
    rows_by_name = client_index[card["set_code"]] or return
    name_candidates(card).each do |name|
      candidates = rows_by_name[name] or next
      match = disambiguate(candidates, card)
      return match if match
    end
    nil
  end

  # A multi-face card is one row in the client, named either after the whole
  # card or after its front face, so both faces of ours look for the same row.
  # The client goes by the printed name where a card has one, which for om1 is
  # every card in the set, and for sld is every Universes Beyond drop.
  def name_candidates(card)
    names = card["names"] ? [card["names"].join(" // "), card["names"].first] : []
    (names + [card["name"], card["flavor_name"]]).compact.uniq.map{|name| normalize_name(name) }
  end

  # A name on its own is not enough: MTGO has one object where we have a
  # printing per finish and per variant, so something has to say which of ours
  # the row is about.
  def disambiguate(candidates, card)
    number_candidates(card).each do |number|
      matching = candidates.select{|row| row[:number] == number }
      return [BY_NUMBER, matching.first] if matching.size == 1
    end

    # Whatever the two of them number it - MTGO numbers some sets in its own
    # order, and om1 alphabetically
    if candidates.size == 1 and only_card_named?(card["set_code"], candidates.first[:name])
      return [BY_NAME, candidates.first]
    end

    # Last resort: the client confirms one of the rows is the id mtgjson
    # already picked. Sets whose numbers are unrelated to MTGO's (prm numbers
    # its promos by catalog id) have nothing else to go on.
    id = mtgjson_id(card)
    matching = candidates.select{|row| row[:id] == id }
    [BY_MTGJSON, matching.first] if matching.size == 1
  end

  # "210a" is our own suffix for one face of a multipart card, so also try the
  # number without it, and the front face's, which is what the client numbers
  # the whole card by
  def number_candidates(card)
    number = card["number"] or return []
    base = base_number(card)
    base == number ? [number] : [number, base, "#{base}a"].uniq
  end

  # The number a multipart card's faces share, which is the card itself.
  # Only a face gets its number cut back: a trailing letter otherwise marks a
  # variant of its own, like brr/64z, the serialized Adaptive Automaton, which
  # is emphatically not brr/64.
  def base_number(card)
    return card["number"] unless multipart?(card)
    card["number"][/\A(.*\d)[a-z]\z/, 1] || card["number"]
  end

  # PatchReversibleCards splits a reversible card into faces and takes its
  # "names" away, but leaves a promo type saying which side each one is
  def multipart?(card)
    card["names"] or card["promo_types"].to_a.grep(/\Areversible/).any?
  end

  def only_card_named?(set_code, name)
    @cards_by_name.dig(set_code, name)&.size == 1
  end

  # {set code => {name => Set[card number, ...]}} - our own printings under
  # every name a client row could be listing them by, the faces sharing one
  # number counting as the one card they are
  def build_name_index
    @cards_by_name = {}
    each_printing do |card|
      names = (@cards_by_name[card["set_code"]] ||= {})
      name_candidates(card).each do |name|
        (names[name] ||= Set[]) << base_number(card)
      end
    end
  end

  # "270/269" is a number out of a set size, "a410" is our "410a"
  def normalize_number(number)
    number = number.to_s.split("/").first.to_s
    return nil if number.empty?
    number.sub(/\A([a-z])(\d+)\z/) { "#{$2}#{$1}" }
  end

  # Diacritics are written the same way on both sides, but not always encoded
  # the same way, so decompose and drop the combining marks. Two more the
  # client spells its own way, and between them that is every name in the
  # catalog the two sides disagree about:
  # - Ratonhnhaké:ton, which the client spells with a colon and we spell with
  #   nothing, PatchCardNames having dropped the modifier letter colon mtgjson
  #   uses because nobody can type it. Dropping every colon costs nothing: 121
  #   names have one (Circle of Protection:, Summon:, Bounty:) and this is the
  #   only one the two sides punctuate differently.
  # - the Unfinity name stickers, whose blank is a run of underscores that the
  #   two of them count differently
  # - the Magic Online Avatars, which the client calls "Avatar - Serra Angel"
  #   where we call them "Serra Angel Avatar", and where it tells two of one
  #   name apart with an "(Alt.)" that our collector numbers already tell apart
  def normalize_name(name)
    name = name.to_s
      .unicode_normalize(:nfd)
      .gsub(/\p{Mn}/, "")
      .delete(":\uA789")
      .gsub(/_+/, "_")
      .downcase
    name.sub(/\Aavatar - (.*?)(?: \(alt\.\))?\z/) { "#{$1} avatar" }
  end

  def mtgjson_id(card)
    card.dig("identifiers", "mtgoId")
  end

  # A set needing fallback is a set we get wrong somewhere, so say how badly,
  # and how many of its client rows are still unaccounted for - the leftovers
  # are where the printings we missed are. A row we did match, to a printing
  # our data calls paper only, is accounted for, so it belongs in the one-line
  # total rather than against its set.
  def report
    unclaimed = client_rows
      .reject{|row| @matched.include?(row[:id]) or @paper_only_ids.include?(row[:id]) }
      .group_by{|row| our_set_codes[row[:mtgo_set]]&.first }

    puts "MTGO ids: #{@matched_printings} printings took a client id, #{@fallbacks.values.sum(&:size)} fell back to mtgjson"

    set_codes = (@fallbacks.keys + @contested.keys + unclaimed.keys).compact.uniq
    set_codes.sort_by{|set_code| [-@fallbacks[set_code].size, set_code] }.each do |set_code|
      cards = @fallbacks[set_code]
      rows = unclaimed[set_code].to_a
      line = "  #{set_code}: #{cards.size} cards fell back, #{rows.size} client entries unmapped"
      line << ", #{@contested[set_code]} lost a contested id" if @contested[set_code] > 0
      puts line
      cards.sort_by{|card| [card["number"].to_i, card["number"]] }.each do |card|
        puts "    fallback #{card["mtgo_id"]} #{card["name"]} [#{set_code}:#{card["number"]}]"
      end
      rows.sort_by{|row| row[:id].to_i }.each do |row|
        puts "    unmapped #{row[:id]} #{row[:printed_name]} [#{row[:mtgo_set]}:#{row[:number]}]"
      end
    end

    if @paper_only_ids.any?
      biggest = @paper_only.sort_by{|set_code, count| [-count, set_code] }.first(10)
      puts "  #{@paper_only_ids.size} client entries are printings we do not call game:mtgo: " +
        biggest.map{|set_code, count| "#{set_code} (#{count})" }.join(", ") + ", ..."
    end

    unmapped_sets = unclaimed[nil].to_a.group_by{|row| row[:mtgo_set] }
    unless unmapped_sets.empty?
      puts "  MTGO sets with no set of ours: " +
        unmapped_sets.sort_by{|code, rows| [-rows.size, code] }.map{|code, rows| "#{code} (#{rows.size})" }.join(", ")
    end
  end
end

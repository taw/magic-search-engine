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
#
# Every row also carries the id of the premium (foil) object for the same card,
# which is a catalog object of its own. It is usually the normal id plus one,
# but not always - CMD, DDC, DDF and UNH file all their foils after all their
# nonfoils, and a few tokens have the premium id first - so it is carried
# through rather than derived.
class PatchMtgoIds < Patch
  # Only CARD rows are cards a deck can name. SUBC is one face of a card the
  # client also lists as a CARD, TOKN is a token, PLAD a helper card. Four
  # rows are typed CARD and flagged as a sub card all the same - the back
  # faces of dka/125, inr/212, inr/468 and mom/72 - and a back face is a back
  # face however it is typed.
  CARD_TYPE = "CARD"

  # How well an id is attested, best first. Two printings that both want one
  # id are resolved in this order, so a guess never displaces a match.
  BY_NUMBER = 0   # the client's number for it is one of ours
  BY_NAME = 1     # one row, one card of ours, one name
  BY_MTGJSON = 2  # several rows, and the client has the one mtgjson picked
  FROM_MTGJSON = 3 # no row at all, so mtgjson's word for it

  # And which set the row was found in, which outranks all of the above: a row
  # filed under a set of ours is about that set's printing, however well some
  # other set's printing matches it. Our prm/86188 Karador is numbered after
  # this very catalog id, and cmr/521 Karador matching the printed set's
  # collector number is not a reason to take it away.
  AT_HOME = 0
  BY_PRINTED_SET = 1

  # The rows the client files under a set of its own choosing, or numbers its
  # own way, as {client set => {client number => [our set code, our number]}}.
  # A row in here goes to that printing and nowhere else.
  REMAPPED_CARDS = {
    # Reversible cards are one piece of cardboard with the same card printed
    # on both sides. We number the two sides 21a and 21b; MTGO has an object
    # per side and no notion of a side, so it numbers them 21 and 22 and
    # carries on, and its REX runs to 32 where ours runs to 26.
    "REX" => {
      "21" => ["rex", "21a"], "22" => ["rex", "21b"],  # Plains
      "23" => ["rex", "22a"], "24" => ["rex", "22b"],  # Island
      "25" => ["rex", "23a"], "26" => ["rex", "23b"],  # Swamp
      "27" => ["rex", "24a"], "28" => ["rex", "24b"],  # Mountain
      "29" => ["rex", "25a"], "30" => ["rex", "25b"],  # Forest
      "31" => ["rex", "26a"], "32" => ["rex", "26b"],  # Command Tower
    },
    # The client's UMA holds the Ultimate Box Toppers, which are puma to us,
    # and pads their numbers to two digits
    "UMA" => (1..40).to_h{|n| ["U%02d" % n, ["puma", "U#{n}"]] },
    # mtgjson has om1 Supportive Parents twice, and the one MTGO has is the
    # dagger one - see PatchMtgjsonBugs, which takes the other off MTGO. The
    # remap is still needed: the two of them are both named Supportive
    # Parents, so nothing but the number could pick the right one.
    "OM1" => {"117" => ["om1", "117†"]},
  }

  def call
    build_face_index
    build_name_index
    @fallbacks = Hash.new{|hash, set_code| hash[set_code] = [] }
    @paper_only_ids = Set[]
    @contested = Hash.new(0)
    @matched = Set[]
    @matched_cards = Set[]
    @matched_printings = 0

    assign(proposals)
    report
  end

  private

  def csv_path
    Indexer::ROOT + "mtgo_ids.csv"
  end

  # [where, rank, card, id, foil id] for every printing we have an id for at all
  def proposals
    result = []
    each_printing do |card|
      rank, row = client_row(card)
      id = row ? row[:id] : mtgjson_id(card)
      next unless id
      # MTGO having an object is not MTGO selling the card
      if !card["mtgo"]
        @paper_only_ids << row[:id] if row
        next
      end
      foil_id = row ? row[:foil_id] : mtgjson_foil_id(card)
      result << [where(row, card), rank || FROM_MTGJSON, card, id, foil_id]
    end
    result
  end

  def where(row, card)
    return BY_PRINTED_SET unless row
    our_set_codes.fetch(row[:mtgo_set], []).include?(card["set_code"]) ? AT_HOME : BY_PRINTED_SET
  end

  # One id belongs to one card, however many faces that card has. Anything
  # else means we matched two of our printings onto one MTGO object, so the
  # worse attested of the two gets nothing rather than something wrong.
  def assign(proposals)
    owners = {}
    proposals.each_with_index.sort_by{|(where, rank, _, _, _), order| [where, rank, order] }.each do |(where, rank, card, id, foil_id), _|
      card_key = [card["set_code"], base_number(card)]
      if owners.fetch(id, card_key) != card_key
        @contested[card["set_code"]] += 1
        next
      end
      owners[id] = card_key
      card["mtgo_id"] = id
      card["mtgo_foil_id"] = foil_id if foil_id
      if rank == FROM_MTGJSON
        @fallbacks[card["set_code"]] << card
      else
        @matched << id
        @matched_printings += 1
        @matched_cards << printing_key(card)
      end
    end
  end

  # Every row in the client's catalog, in the client's own terms
  def all_rows
    @all_rows ||= CSV.read(csv_path, headers: true)
      .map{|row| {
        id: row["Id"],
        mtgo_set: row["Set"],
        printed_set: row["Printed Set"],
        name: normalize_name(row["Name"]),
        printed_name: row["Name"],
        number: normalize_number(row["Number"]),
        foil_id: presence(row["Foil Id"]),
        whole_card: row["Type"] == CARD_TYPE && row["Sub Card"].to_s.empty?,
      }}
  end

  def rows_by_id
    @rows_by_id ||= all_rows.to_h{|row| [row[:id], row] }
  end

  # One row per printing a deck can name, which is what gets matched
  def client_rows
    @client_rows ||= all_rows.select{|row| row[:whole_card] }
  end

  # {our set code => {name => [row, ...]}}. An MTGO set that holds cards from
  # several sets of ours offers its rows to each of them, and the one card one
  # id rule sorts out anything that two of them both want.
  def client_index
    @client_index ||= begin
      index = {}
      client_rows.each do |row|
        target_set_codes(row).each do |set_code|
          ((index[set_code] ||= {})[row[:name]] ||= []) << row
        end
      end
      index
    end
  end

  # A row's set is the bucket MTGO files it under, which for a promo or a
  # supplementary product is not the set it was printed in: Vorinclex is filed
  # under ONE and printed in KHM, and it is khm/406 to us. Both are tried, and
  # a printing in the bucket beats one in the printed set when they collide.
  def target_set_codes(row)
    set_code, _number = remapped(row)
    return [set_code] if set_code
    our_set_codes.fetch(row[:mtgo_set], []) | our_set_codes.fetch(row[:printed_set], [])
  end

  # [our set code, our number] for a row we have written down, else nil
  def remapped(row)
    REMAPPED_CARDS.dig(row[:mtgo_set], row[:number]) || []
  end

  # A row's number in the terms of the set of ours it is being offered to
  def our_number(row, set_code)
    remapped_set, number = remapped(row)
    remapped_set == set_code ? number : row[:number]
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
  # every card in the set, and for sld is every Universes Beyond drop - and
  # that printed name lives on the face it belongs to, so a back face has to
  # ask its front for it. om1/71b is Venom, Lethal Protector to us and the back
  # of "Viggo, Enforcer of Ig's Crossing" to MTGO.
  def name_candidates(card)
    names = card["names"] ? [card["names"].join(" // "), card["names"].first] : []
    names += [card["name"]]
    names += faces_of(card).map{|face| face["flavor_name"] }
    names.compact.uniq.map{|name| normalize_name(name) }
  end

  # Every face of the card this printing is one face of, front first
  def faces_of(card)
    @faces.fetch([card["set_code"], base_number(card)], [card])
  end

  def build_face_index
    @faces = {}
    each_printing do |card|
      (@faces[[card["set_code"], base_number(card)]] ||= []) << card
    end
    @faces.each_value{|cards| cards.sort_by!{|card| card["number"] } }
  end

  # A name on its own is not enough: MTGO has one object where we have a
  # printing per finish and per variant, so something has to say which of ours
  # the row is about.
  def disambiguate(candidates, card)
    number_candidates(card).each do |number|
      matching = candidates.select{|row| our_number(row, card["set_code"]) == number }
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
    cards = @cards_by_name.dig(set_code, name) or return false
    cards.map{|card| base_number(card) }.uniq.size == 1
  end

  # Could a row have produced an id whichever of our printings it picked? Only
  # if one of them is still waiting for one. A printing we do not call
  # game:mtgo was never going to take an id; one that already took a client id
  # has the object it asked for, and this one is MTGO having more objects for
  # a card than we have printings of it, which is nothing we can act on. A
  # printing that only fell back to mtgjson does still count, because a row
  # that could be it is a row that could have been matched properly.
  def could_have_mattered?(row)
    target_set_codes(row).any? do |set_code|
      @cards_by_name.dig(set_code, row[:name])&.any? do |card|
        card["mtgo"] and not @matched_cards.include?(printing_key(card))
      end
    end
  end

  # A printing, which is a collector number in a set
  def printing_key(card)
    [card["set_code"], card["number"]]
  end

  # {set code => {name => [card, ...]}} - our own printings under every name a
  # client row could be listing them by
  def build_name_index
    @cards_by_name = {}
    each_printing do |card|
      names = (@cards_by_name[card["set_code"]] ||= {})
      name_candidates(card).each do |name|
        (names[name] ||= []) << card
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

  # mtgjson's id, unless the client's own catalog contradicts it. Two ways it
  # does. The id can be some other card: mtgjson matches by collector number,
  # and where the client numbers a set its own way that is a coincidence and
  # not a match, so all fifteen of dpa's were another card carrying our number
  # (dpa/3 Cancel took 34047, which the client calls Angelic Blessing at
  # 3/383). Or the id can be no whole card at all: pip's surge foil James,
  # Wandering Dad took 132311, which is the SUBC row for the Follow Him half,
  # and a .dek can no more name that than it can name a token.
  #
  # What survives is the ids we cannot contradict - premium objects, which
  # have no row of their own, only a Foil Id - and cards the client files
  # somewhere we did not look.
  def mtgjson_id(card)
    id = card.dig("identifiers", "mtgoId") or return
    row = rows_by_id[id] or return id
    return unless row[:whole_card] and name_candidates(card).include?(row[:name])
    id
  end

  def mtgjson_foil_id(card)
    card.dig("identifiers", "mtgoFoilId")
  end

  def presence(value)
    value unless value.to_s.empty?
  end

  # A set needing fallback is a set we get wrong somewhere, so say how badly,
  # and how many of its client rows are still unaccounted for - the leftovers
  # are where the printings we missed are. A row that could never have produced
  # an id is not a leftover: whether it matched a paper only printing or could
  # not choose between several of them, no id was ever going to come of it.
  def report
    unclaimed = client_rows
      .reject{|row| @matched.include?(row[:id]) or @paper_only_ids.include?(row[:id]) }
      .select{|row| could_have_mattered?(row) }
      .group_by{|row| target_set_codes(row).first }

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

    # Not subject to any of the filtering above: a client set we have no set
    # for is how a set MTGO has just added announces itself
    unmapped_sets = client_rows
      .select{|row| target_set_codes(row).empty? }
      .group_by{|row| row[:mtgo_set] }
    unless unmapped_sets.empty?
      puts "  MTGO sets with no set of ours: " +
        unmapped_sets.sort_by{|code, rows| [-rows.size, code] }.map{|code, rows| "#{code} (#{rows.size})" }.join(", ")
    end
  end
end

# One of these per booster, built while the index loads and thrown away once
# the pack is. The database is still needed - CardSheetFactory runs queries
# against it, and a sheet can be built out of another set's deck - but
# everything about *this* booster is passed in.
class PackFactory
  def initialize(db, set, variant, data)
    @db = db
    @set = set
    @data = data
    @code = [set.code, variant].compact.join("-")
    @sheet_factory = CardSheetFactory.new(db)
  end

  def build_pack
    sheets = @data["sheets"].to_h{|sheet_name, sheet_data|
      [sheet_name, build_top_level_sheet(sheet_name, sheet_data)]
    }
    subpacks = @data["pack"].map{|subpack_data, chance|
      [build_simple_pack(subpack_data, sheets), chance]
    }
    pack = subpacks.size == 1 ? subpacks[0][0] : WeightedPack.new(subpacks.to_h)

    pack.set = @set
    pack.code = @code
    pack.name = @data["name"]&.gsub("{set_name}", @set.name) || @code
    pack.languages = @data["languages"] || @set.languages
    # Sanity check against mtgjson - a booster can be printed in fewer languages
    # than its set, never in more. Report only, as mtgjson set data changes too.
    extra_languages = pack.languages - @set.languages
    unless extra_languages.empty?
      warn "#{@code}: languages #{extra_languages.join(", ")} not printed for set #{@set.code} (#{@set.languages.join(", ")})"
    end
    pack
  end

  private

  def raise_sheet_error(message)
    raise "Error building #{@sheet_full_name}: #{message}"
  end

  def build_sheet_from_subsheets(subsheets, chances, kind: CardSheet, count: nil)
    # Filter out the empty subsheets
    # Example: foil sheet has 2xR + 1xM mix, but some sets don't have mythics
    subsheets, chances = subsheets.zip(chances).select{|s,c| c != 0}.transpose
    raise_sheet_error "No subsheets present" unless subsheets
    if subsheets.size == 1
      if kind != subsheets[0].class
        warn "#{@sheet_full_name}: Sheet has only one subsheet and it has wrong kind, expected #{kind}, got #{subsheets[0].class}"
      end
      result = subsheets[0]
    else
      result = kind.new(subsheets, chances)
    end
    if count and count != result.count
      warn "#{@sheet_full_name}: Expected sheet to have #{count} cards, got #{result.count}"
    end
    result
  end

  def build_sheet_from_deck(deck_code, finish: :nonfoil, count: nil)
    set_code, deck_name = deck_code.split("/", 2)
    set = @db.sets[set_code]
    raise_sheet_error "Cannot resolve deck #{deck_code}, no set #{set_code} found" unless set
    deck = set.decks.find{|d| d.name == deck_name}
    raise_sheet_error "Cannot resolve deck #{deck_code}, no deck with such name found for #{set_code}" unless deck
    deck_cards = deck.all_cards.select{|k,v| v.finish == finish}
    if count
      actual_count = deck_cards.map(&:first).sum
      unless actual_count == count
        warn "Expected deck #{deck_code} to return #{count} with finish: #{finish}, got #{actual_count}"
      end
    end
    FixedCardSheet.new(deck_cards.map(&:last), deck_cards.map(&:first))
  end

  # Sheets name their finish as `foil` and `etched` flags, the way the sealed
  # data does, but everything below here wants the one value PhysicalCard
  # stores. `inherited_finish` is what an `any` subsheet gets when it does not
  # name a finish of its own.
  def read_finish(data, inherited_finish)
    return inherited_finish unless data.has_key?("foil") or data.has_key?("etched")
    etched = data.delete("etched")
    foil = data.delete("foil")
    # etched is a kind of foiling, so the `foil: true` next to it is redundant
    # rather than contradictory, same as in PhysicalCard.for
    if etched
      :etched
    elsif foil
      :foil
    else
      :nonfoil
    end
  end

  def build_sheet(data, inherited_finish=:nonfoil)
    data = data.dup
    balanced = false
    fixed = false

    finish = read_finish(data, inherited_finish)
    balanced = data.delete("balanced") if data.has_key?("balanced")
    duplicates = data.delete("duplicates") if data.has_key?("duplicates")
    count = data.delete("count") if data.has_key?("count")
    fixed = data.delete("fixed") if data.has_key?("fixed")

    if [balanced, duplicates, fixed].count(&:itself) > 1
      raise_sheet_error "Sheet types are mutually exclusive"
    elsif balanced
      kind = ColorBalancedCardSheet
    elsif duplicates
      kind = CardSheetWithDuplicates
    elsif fixed
      kind = FixedCardSheet
    else
      kind = CardSheet
    end

    case data.keys
    when ["code"]
      raise_sheet_error "No balanced support for code" if balanced
      parts = data["code"].split("/", 2)
      @sheet_factory.explicit_sheet(parts[0], parts[1], finish: finish, count: count, kind: kind)
    when ["query"]
      @sheet_factory.from_query(data["query"], count, finish: finish, kind: kind)
    when ["any"]
      subsheets = data["any"].map(&:dup)
      if subsheets.all?{|s| s["rate"]}
        rates = subsheets.map{|d| d.delete("rate")}
        sheets = subsheets.map{|d| build_sheet(d, finish) }
        chances = rates.zip(sheets).map{|r,s| r*s.elements.size}
        build_sheet_from_subsheets(sheets, chances, kind: kind, count: count)
      elsif subsheets.all?{|s| s["chance"]}
        chances = subsheets.map{|d| d.delete("chance")}
        sheets = subsheets.map{|d| build_sheet(d, finish) }
        build_sheet_from_subsheets(sheets, chances, kind: kind, count: count)
      else
        raise_sheet_error "Incorrect subsheet data for any"
      end
    when ["deck"]
      raise_sheet_error "No balanced support for code" if balanced
      raise_sheet_error "No duplicates support for code" if duplicates
      build_sheet_from_deck(data["deck"], finish: finish, count: count)
    else
      raise_sheet_error "Unknown sheet type #{data.keys.join(", ")}"
    end
  end

  def build_top_level_sheet(sheet_name, data)
    @sheet_full_name = "#{@set.code}/#{sheet_name}"
    sheet = build_sheet(data)
    sheet.name = sheet_name
    sheet
  ensure
    @sheet_full_name = nil
  end

  def build_simple_pack(pack_data, sheets)
    Pack.new(pack_data.map{|name, count|
      sheet = sheets[name] or raise "Can't build sheet #{name}"
      [sheet, count]
    }.to_h)
  end
end

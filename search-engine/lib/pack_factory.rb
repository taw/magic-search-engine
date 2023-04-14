class PackFactory
  def initialize(db)
    @db = db
    @sheet_factory = CardSheetFactory.new(@db)
  end

  def raise_sheet_error(message)
    raise "Error building #{@sheet_full_name}: #{message}"
  end

  def build_sheet_from_subsheets(subsheets, chances)
    # Filter out the empty subsheets
    # Example: foil sheet has 2xR + 1xM mix, but some sets don't have mythics
    subsheets, chances = subsheets.zip(chances).select{|s,c| c != 0}.transpose
    raise_sheet_error "No subsheets present" unless subsheets
    if subsheets.size == 1
      subsheets[0]
    else
      CardSheet.new(subsheets, chances)
    end
  end

  def build_sheet(data)
    data = data.dup
    foil = false
    balanced = false
    coout = nil

    foil = data.delete("foil") if data.has_key?("foil")
    balanced = data.delete("balanced") if data.has_key?("balanced")
    count = data.delete("count") if data.has_key?("count")
    kind = balanced ? ColorBalancedCardSheet : CardSheet

    case data.keys
    when ["code"]
      raise_sheet_error "No balanced support for code" if balanced
      parts = data["code"].split("/", 2)
      @sheet_factory.explicit_sheet(parts[0], parts[1], foil: foil, count: count)
    when ["query"]
      @sheet_factory.from_query(data["query"], count, foil: foil, kind: kind)
    when ["any"]
      subsheets = data["any"].map(&:dup)
      raise_sheet_error "No balanced support for any" if balanced
      if subsheets.all?{|s| s["rate"]}
        rates = subsheets.map{|d| d.delete("rate")}
        sheets = subsheets.map{|d| build_sheet(d.merge("foil" => foil)) }
        chances = rates.zip(sheets).map{|r,s| r*s.elements.size}
        build_sheet_from_subsheets(sheets, chances)
      elsif subsheets.all?{|s| s["chance"]}
        chances = subsheets.map{|d| d.delete("chance")}
        sheets = subsheets.map{|d| build_sheet(d.merge("foil" => foil)) }
        build_sheet_from_subsheets(sheets, chances)
      else
        raise_sheet_error "Incorrect subsheet data for any"
      end
    else
      raise_sheet_error "Unknown sheet type #{data.keys.join(", ")}"
    end
  end

  def build_top_level_sheet(set_code, sheet_name, data)
    @sheet_full_name = "#{set_code}/#{sheet_name}"
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

  def for(set_code, variant=nil)
    variant = nil if variant == "default"
    set = @db.resolve_edition(set_code)
    raise "Invalid set code #{set_code}" unless set
    set_code = set.code # Normalize
    booster_code = [set_code, variant].compact.join("-")
    data = @db.booster_data[booster_code]

    return nil unless data

    sheets = data["sheets"].map{|sheet_name, sheet_data|
      [sheet_name, build_top_level_sheet(set_code, sheet_name, sheet_data)]
    }.to_h
    subpacks = data["pack"].map{|subpack_data, chance|
      subpack = build_simple_pack(subpack_data, sheets)
      [subpack, chance]
    }
    if subpacks.size == 1
      pack = subpacks[0][0]
    else
      pack = WeightedPack.new(subpacks.to_h)
    end

    pack.set = set
    pack.code = booster_code
    pack.name = data["name"]&.gsub("{set_name}", set.name) || booster_code
    pack
  end
end

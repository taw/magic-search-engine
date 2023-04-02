class PackFactoryYaml
  def initialize(db, sheet_factory)
    @db = db
    @sheet_factory = sheet_factory
  end

  def build_sheet_from_yaml_data(set_code, name, data)
    data = data.dup
    foil = false
    balanced = false
    coout = nil

    foil = data.delete("foil") if data.has_key?("foil")
    balanced = data.delete("balanced") if data.has_key?("balanced")
    count = data.delete("count") if data.has_key?("count")
    kind = balanced ? ColorBalancedCardSheet : CardSheet

    sheet = case data.keys.sort
    when ["code"]
      raise "No balanced support for #{set_code}:code" if balanced
      @sheet_factory.explicit_sheet(set_code, data["code"], foil: foil, count: count)
    when ["code", "set"]
      raise "No balanced support for #{set_code}:code" if balanced
      @sheet_factory.explicit_sheet(data["set"], data["code"], foil: foil, count: count)
    when ["query"]
      @sheet_factory.from_query("e:#{set_code} (#{data["query"]})", count, foil: foil, kind: kind)
    when ["rawquery"]
      @sheet_factory.from_query(data["rawquery"], count, foil: foil, kind: kind)
    when ["any"]
      subsheets = data["any"].map(&:dup)
      raise "No balanced support for #{set_code}:any" if balanced
      if subsheets.all?{|s| s["rate"]}
        chances = subsheets.map{|d| d.delete("rate")}
        sheets = subsheets.map{|d|
          build_sheet_from_yaml_data(set_code, nil, d.merge("foil" => foil))
        }
        CardSheet.new(
          sheets,
          chances.zip(sheets).map{|c,s| c*s.elements.size}
        )
      elsif subsheets.all?{|s| s["chance"]}
        chances = subsheets.map{|d| d.delete("chance")}
        sheets = subsheets.map{|d|
          build_sheet_from_yaml_data(set_code, nil, d.merge("foil" => foil))
        }
        CardSheet.new(
          sheets,
          chances
        )
      else
        raise "Incorrect subsheet data for #{set_code} any"
      end
    else
      raise "Unknown sheet type #{data.keys.join(", ")}"
    end
    sheet.name = name if name
    sheet
  end

  def build_simple_pack(pack_data, sheets)
    Pack.new(pack_data.map{|name, count|
      sheet = sheets[name] or raise "Can't build sheet #{name}"
      [sheet, count]
    }.to_h)
  end

  def build_pack(set, full_variant)
    set_code = set.code

    if full_variant == "yaml"
      variant = nil
    else
      variant = full_variant.sub("-yaml", "")
    end
    data = @db.booster_data["boosters"][[set_code, variant].compact.join("-")]

    return nil unless data

    sheets = data["sheets"].map{|sheet_name, sheet_data|
      [sheet_name, build_sheet_from_yaml_data(set_code, sheet_name, sheet_data)]
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
    pack.code = "#{set_code}-#{full_variant}"
    if variant
      pack.name = set.booster_variants[variant]
    else
      pack.name = set.name
    end
    pack
  end
end

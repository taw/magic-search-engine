class PackFactoryYaml
  def initialize(db, sheet_factory)
    @db = db
    @sheet_factory = sheet_factory
  end

  def default_sheets
    @default_sheets ||= YAML.load_file(Pathname(__dir__) + "../../data/boosters/common.yaml")
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

  def path_for(set, variant)
    root = Pathname(__dir__) + "../../data/boosters"
    set_code = set.code
    set_code += "_" if set_code == "con"
    if variant
      root + "#{set_code}-#{variant}.yaml"
    else
      root + "#{set_code}.yaml"
    end
  end

  def merge_pack_parts(part1, part2)
    result = part1.dup
    part2.each do |k, v|
      result[k] ||= 0
      result[k] += v
    end
    result
  end

  def build_simple_pack(pack_data, sheets)
    Pack.new(pack_data.map{|name, count|
      sheet = sheets[name] or raise "Can't build sheet #{name}"
      [sheet, count]
    }.to_h)
  end

  def resolve_option_combinations(pack_data)
    options = [[{}, 1]]
    pack_data.each do |name, count|
      if count.is_a?(Integer)
        options = options.map{|o,c|
          [merge_pack_parts(o, {name => count}), c]
        }
      elsif count.is_a?(Array)
        merge_options = count.map{|m| [m, m.delete("chance")]}
        options = options.flat_map{|o1, c1|
          merge_options.map{|o2, c2|
            [merge_pack_parts(o1, o2), c1 * c2]
          }
        }
      else
        raise "Unknown pack count type #{count.class}"
      end
    end
    options
  end

  def build_pack_with_alternatives(pack_data, sheets)
    if pack_data.all?{|k,v| v.is_a?(Integer)}
      return build_simple_pack(pack_data, sheets)
    end

    options = resolve_option_combinations(pack_data)

    if options.size == 1
      # Not very likely, but technically possible
      build_simple_pack(options[0][0], sheets)
    else
      gcd = options.map(&:last).inject(&:gcd)
      WeightedPack.new(options.map{|subpack_data, chance|
        [build_simple_pack(subpack_data, sheets), chance / gcd]
      }.to_h)
    end
  end

  def build_pack(set, full_variant)
    set_code = set.code

    if full_variant == "yaml"
      variant = nil
    else
      variant = full_variant.sub("-yaml", "")
    end
    path = path_for(set, variant)

    return nil unless path.exist?

    data = YAML.load_file(path)
    sheets = Hash.new{|ht,k|
      ht[k] = build_sheet_from_yaml_data(set_code, k, default_sheets[k]) if default_sheets[k]
    }
    (data.delete("sheets") || []).each{|sheet_name, sheet_data|
      sheets[sheet_name] = build_sheet_from_yaml_data(set_code, sheet_name, sheet_data)
    }
    pack = case data.keys
    when ["pack"]
      build_pack_with_alternatives(data["pack"], sheets)
    when ["packs"]
      WeightedPack.new(data["packs"].map{|subpack_data|
        chance = subpack_data.delete("chance")
        subpack = build_pack_with_alternatives(subpack_data, sheets)
        [subpack, chance]
      }.to_h)
    else
      raise "Unknown pack type #{data.keys.join(", ")}"
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

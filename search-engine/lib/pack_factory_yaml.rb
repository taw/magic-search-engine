class PackFactoryYaml
  def initialize(db, sheet_factory)
    @db = db
    @sheet_factory = sheet_factory
  end

  # Most common sheets that would be pointless to repeat in every single yaml file
  # These names are not reserved and can be overriden by individual YAML files
  def default_sheets
    @default_sheets ||= YAML.load('
    rare_mythic:
      any:
      - query: "r:r"
        rate: 2
      - query: "r:m"
        rate: 1
    rare:
      query: "r:r"
    uncommon:
      query: "r:u"
    common:
      balanced: true
      query: "r:c"
    basic:
      query: "r:b"
    foil:
      foil: true
      any:
        - query: "r<=c"
          chance: 12
        - query: "r:u"
          chance: 5
        - any:
          - query: "r:r"
            rate: 2
          - query: "r:m"
            rate: 1
          chance: 3
    ')
  end

  def build_sheet_from_yaml_data(set_code, name, data)
    data = data.dup
    foil = false
    balanced = false
    coout = nil

    foil = data.delete("foil") if data.has_key?("foil")
    balanced = data.delete("balanced") if data.has_key?("balanced")
    count = data.delete("count") if data.has_key?("count")

    sheet = case data.keys.sort
    when ["code"]
      raise "No balanced support for #{set_code}:code" if balanced
      raise "No count check support for #{set_code}:code" if count # TODO
      @sheet_factory.explicit_sheet(set_code, data["code"], foil: foil)
    when ["code", "set"]
      raise "No balanced support for #{set_code}:code" if balanced
      raise "No count check support for #{set_code}:code" if count # TODO
      @sheet_factory.explicit_sheet(data["set"], data["code"], foil: foil)
    when ["query"]
      kind = balanced ? ColorBalancedCardSheet : CardSheet
      @sheet_factory.from_query("e:#{set_code} (#{data["query"]})", count, foil: foil, kind: kind)
    when ["rawquery"]
      kind = balanced ? ColorBalancedCardSheet : CardSheet
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
    if variant
      path = root + "#{set.code}-#{variant}.yaml"
    else
      path = root + "#{set.code}.yaml"
    end
  end

  def build_pack_from_data(pack_data, sheets)
    Pack.new(pack_data.map{|name, weight|
      sheet = sheets[name] or raise "Can't build sheet #{name} for #{set_code}"
      [sheet, weight]
    }.to_h)
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
      packs_array = [{"chance": 1}]
      data["pack"].each do |slot_name, slot_data|
        if slot_data.is_a? Integer
          packs_array.map!{|pack_type| pack_type.has_key?(slot_name) ? pack_type[slot_name] += slot_data : pack_type.store(slot_name, slot_data)}
        else
          slot_data.delete("count").times do
            newpacks = []
            packs_array.each do |pack_type|
              case slot_data.keys |sd|
              when ["sheet"]
                slot_data["sheets"].each do |sheet_name, sheet_rate|
                temp = pack_type.merge({"chance": pack_type["chace"] * sheet_rate})
                if tpack.has_key?(sheet_name)
                  temp[sheet_name] += 1
                else
                  temp[sheet_name] = 1
                end
                newpacks << temp
              end
            end
            packs_array = newpacks
          end
        end
      end
      WeightedPack.new(packs_array.map{|subpack_data|
        chance = subpack_data.delete("chance")
        subpack = build_pack_from_data(subpack_data, sheets)
        [subpack, chance]
      }.to_h)
    when ["packs"]
      WeightedPack.new(data["packs"].map{|subpack_data|
        chance = subpack_data.delete("chance")
        subpack = build_pack_from_data(subpack_data, sheets)
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

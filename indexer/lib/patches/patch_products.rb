class PatchProducts < Patch
  def call
    @products.each do |product|
      product["contents"] = parse_contents(product["contents"] || [])
    end

    # TODO: simplify products that are just packs
  end

  def parse_contents(contents)
    result = []
    if contents.empty?
      result << [1, "unknown"]
    end

    contents.each do |key, val|
      case key
      when "sealed"
        val.each do |v|
          result << [v["count"], "product", v["set"], v["name"]]
        end
      when "pack"
        val.each do |v|
          if v["code"] == "default"
            pack_code = v["set"]
          else
            pack_code = "#{v["set"]}-#{v["code"]}"
          end
          result << [1, "pack", pack_code]
        end
      when "other"
        # There's a lot of weird stuff here
        # Some of it could be converted to something more meaningful
        val.each do |v|
          result << [1, "other", v["name"]]
        end
      when "deck"
        val.each do |v|
          result << [1, "deck", v["set"], v["name"]]
        end
      when "card"
        val.each do |v|
          foil = v["foil"] || v["finishes"] == ["foil"]
          set_code = v["set"]
          number = v["number"]
          name = v["name"]
          if !@cards[name]
            # Fail, but allow for now
            result << [1, "card", set_code, number, name, !!foil]
          elsif @cards[name].find{|p| p["set_code"] == set_code and p["number"] == number}
            result << [1, "card", set_code, number, name, !!foil]
          elsif @cards[name].find{|p| p["set_code"] == set_code and p["number"] == number + "a"}
            # DFC
            result << [1, "card", set_code, number + "a", name, !!foil]
          else
            # Fail, but allow for now
            result << [1, "card", set_code, number, name, !!foil]
          end
        end
      when "variable"
        raise unless val.size == 1 and val[0].keys == ["configs"]
        configs = val[0]["configs"]
        subproducts = configs.map do |config|
          {
            "chance" => config.dig("variable_config", 0, "chance") || 1,
            "subproduct" => parse_contents(config.except("variable_config")),
          }
        end
        total = subproducts.map{|c| c["chance"]}.sum
        subproducts.each do |c|
          c["total"] = total
        end
        result << [1, "variable", subproducts]
      else
        raise "Unknown product contents key: #{key}"
      end
    end

    result
  end
end

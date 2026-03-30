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
      result << [1, "unknown_contents"]
    end

    contents.each do |key, val|
      case key
      when "sealed"
        val.each do |v|
          result << [v["count"], "product", v["set"], v["name"]]
        end
      when "pack"
        val.each do |v|
          result << [1, "pack", v["set"], v["code"]]
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
          result << [1, "card", v["set"], v["number"], v["name"], v["finishes"]]
        end
      when "variable"
        # For now I'll just skip them and implement the rest of the system
        result << [1, "variable_contents", val]
      else
        raise "Unknown product contents key: #{key}"
      end
    end

    result
  end
end

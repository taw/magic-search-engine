class PatchNormalizeColors < Patch
  def call
    each_printing do |card|
      color_codes = {"W"=>"w", "U"=>"u", "B"=>"b", "R"=>"r", "G"=>"g"}
      colors = card["colors"] || []
      card["colors"] = colors.map{|c| color_codes.fetch(c)}.sort.join
      ci = card.delete("colorIdentity") || []
      card["ci"] = ci.map{|c| color_codes.fetch(c)}.sort.join
    end
  end
end

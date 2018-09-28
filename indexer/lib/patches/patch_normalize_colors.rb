class PatchNormalizeColors < Patch
  def call
    each_printing do |card|
      color_codes = {
        # v3
        "White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g",
        # v4
        "W"=>"w", "U"=>"u", "B"=>"b", "R"=>"r", "G"=>"g",
      }
      colors = card["colors"] || []
      card["colors"] = colors.map{|c| color_codes.fetch(c)}.sort.join
    end
  end
end

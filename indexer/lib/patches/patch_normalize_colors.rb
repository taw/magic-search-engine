class PatchNormalizeColors < Patch
  def call
    each_printing do |card|
      color_codes = {"White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g"}
      colors = card["colors"] || []
      card["colors"] = colors.map{|c| color_codes.fetch(c)}.sort.join
    end
  end
end

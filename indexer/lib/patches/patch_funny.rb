class PatchFunny < Patch
  def call
    errata_sets = @sets.select{|set| set["types"].include?("errata")}.map{|set| set["code"].downcase}
    funny_sets = @sets.select{|set| set["funny"]}.map{|set| set["code"].downcase}

    each_card do |name, printings|
      funny = printings.all?{|card|
        funny_sets.include?(card["set_code"]) or
        errata_sets.include?(card["set_code"]) or
        card["stamp"] == "acorn"
      }

      if funny
        printings.each do |printing|
          printing["funny"] = true
        end
      end
    end
  end
end

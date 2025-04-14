class PatchFunny < Patch
  def call
    # additional funny cards that don't follow the rules
    funny_cards = [
      "Blacker Lotus", # SLD printing with triagle stamp for some reason
    ].to_set

    errata_sets = @sets.select{|set| set["types"].include?("errata")}.map{|set| set["code"].downcase}
    funny_sets = @sets.select{|set| set["funny"]}.map{|set| set["code"].downcase}

    each_card do |name, printings|
      funny = printings.any?{|card| card["stamp"] == "acorn" or card["stamp"] == "heart" }
      # For cards predating stamp system
      funny ||= printings.all?{|card|
        funny_sets.include?(card["set_code"]) or
        errata_sets.include?(card["set_code"])
      }
      funny ||= funny_cards.include?(name)

      if funny
        printings.each do |printing|
          printing["funny"] = true
        end
      end
    end
  end
end

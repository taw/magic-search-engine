class PatchCommander < Patch
  def call
    each_printing do |printing|
      next if printing["secondary"]
      supertypes = printing["supertypes"] || []
      types = printing["types"] || []
      subtypes = printing["subtypes"] || []
      text = printing["text"] || ""

      next unless supertypes.include?("Legendary")

      if types.include?("Creature") or subtypes.include?("Vehicle")
        printing["commander"] = true
        printing["brawler"] = true
      elsif subtypes.include?("Spacecraft")
        if printing["power"]
          printing["commander"] = true
          printing["brawler"] = true
        end
      elsif text.include?("can be your commander")
        printing["commander"] = true
        printing["brawler"] = true
      elsif printing["name"] == "Grist, the Hunger Tide"
        # Unique templating
        printing["commander"] = true
        printing["brawler"] = true
      elsif types.include?("Planeswalker")
        printing["brawler"] = true
      end
    end
  end
end

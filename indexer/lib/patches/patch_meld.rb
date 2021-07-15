class PatchMeld < Patch
  def call
    each_printing do |card|
      # mtgjson has completely random names here, without any system
      # just override them all with the correct ones
      if card["layout"] == "meld"
        card["names"] = case card["name"]
        when "Bruna, the Fading Light", "Gisela, the Broken Blade"
          [card["name"], "Brisela, Voice of Nightmares"]
        when "Graf Rats", "Midnight Scavengers"
          [card["name"], "Chittering Host"]
        when "Hanweir Battlements", "Hanweir Garrison"
          [card["name"], "Hanweir, the Writhing Township"]
        when "Brisela, Voice of Nightmares"
          [
            "Bruna, the Fading Light",
            "Gisela, the Broken Blade",
            "Brisela, Voice of Nightmares",
          ]
        when "Chittering Host"
          [
            "Graf Rats",
            "Midnight Scavengers",
            "Chittering Host",
          ]
        when "Hanweir, the Writhing Township"
          [
            "Hanweir Battlements",
            "Hanweir Garrison",
            "Hanweir, the Writhing Township",
          ]
        else
          raise "No front names for melded card: #{card["name"]}"
        end
      end
    end
  end
end

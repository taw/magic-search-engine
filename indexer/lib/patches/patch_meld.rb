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
        when "Mishra, Claimed by Gix", "Phyrexian Dragon Engine"
          [card["name"], "Mishra, Lost to Phyrexia"]
        when "Titania, Voice of Gaea", "Argoth, Sanctum of Nature"
          [card["name"], "Titania, Gaea Incarnate"]
        when "The Mightstone and Weakstone", "Urza, Lord Protector"
          [card["name"], "Urza, Planeswalker"]
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
        when "Mishra, Lost to Phyrexia"
          [
            "Mishra, Claimed by Gix",
            "Phyrexian Dragon Engine",
            "Mishra, Lost to Phyrexia",
          ]
        when "Titania, Gaea Incarnate"
          [
            "Titania, Voice of Gaea",
            "Argoth, Sanctum of Nature",
            "Titania, Gaea Incarnate",
          ]
        when "Urza, Planeswalker"
          [
            "The Mightstone and Weakstone",
            "Urza, Lord Protector",
            "Urza, Planeswalker",
          ]
        else
          raise "No front names for melded card: #{card["name"]}"
        end
      end
    end
  end
end

# This data should be possible to infer from mtgjson
# It is hardcoded it here, as there were many issues with mtgjson meld card data in the past
# and the number of affected cards is very small
class PatchMeld < Patch
  # Top half first, then bottom half, then the melded card.
  # Top and bottom are how the two backs physically assemble, and they are not
  # something mtgjson records. Sources: Eldritch Moon release notes say outright
  # that Brisela's top half is on the back of Gisela's card, The Brothers' War
  # release notes say the same for Titania and label the Mishra and Urza images
  # "(top)" / "(bottom)", and retailers sell the rest as "... (Top)" / "(Bottom)".
  MeldCards = [
    [
      "Gisela, the Broken Blade",
      "Bruna, the Fading Light",
      "Brisela, Voice of Nightmares",
    ],
    [
      "Graf Rats",
      "Midnight Scavengers",
      "Chittering Host",
    ],
    [
      "Hanweir Battlements",
      "Hanweir Garrison",
      "Hanweir, the Writhing Township",
    ],
    [
      "Mishra, Claimed by Gix",
      "Phyrexian Dragon Engine",
      "Mishra, Lost to Phyrexia",
    ],
    [
      "Titania, Voice of Gaea",
      "Argoth, Sanctum of Nature",
      "Titania, Gaea Incarnate",
    ],
    [
      "Urza, Lord Protector",
      "The Mightstone and Weakstone",
      "Urza, Planeswalker",
    ],
    [
      "Vanille, Cheerful l'Cie",
      "Fang, Fearless l'Cie",
      "Ragnarok, Divine Deliverance",
    ],
  ]

  def call
    map = {}
    secondary = Set[]
    MeldCards.each do |a,b,c|
      map[a] = [a,c]
      map[b] = [b,c]
      map[c] = [a,b,c]
      secondary << c
    end

    each_printing do |card|
      if card["layout"] == "meld"
        name = card["name"]
        raise "Unknown meld card: #{name}" unless map[name]
        card["names"] = map[name]
        card["secondary"] = true if secondary.include?(name)
      end
    end
  end
end

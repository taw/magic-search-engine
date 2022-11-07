# This data should be possible to infer from mtgjson
# It is hardcoded it here, as there were many issues with mtgjson meld card data in the past
# and the number of affected cards is very small
class PatchMeld < Patch
  # melded one last
  MeldCards = [
    [
      "Bruna, the Fading Light",
      "Gisela, the Broken Blade",
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
      "The Mightstone and Weakstone",
      "Urza, Lord Protector",
      "Urza, Planeswalker",
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

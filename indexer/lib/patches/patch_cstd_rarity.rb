# Fix rarities of Coldsnap Theme Decks
# https://github.com/mtgjson/mtgjson/issues/454
class PatchCstdRarity < Patch
  CSTD_RARITY_MAP = {
    "Arcum's Weathervane" => "uncommon",
    "Ashen Ghoul" => "uncommon",
    "Aurochs" => "common",
    "Balduvian Dead" => "uncommon",
    "Barbed Sextant" => "common",
    "Binding Grasp" => "uncommon",
    "Bounty of the Hunt" => "uncommon",
    "Brainstorm" => "common",
    "Browse" => "uncommon",
    "Casting of Bones" => "common",
    "Dark Banishing" => "common",
    "Dark Ritual" => "common",
    "Deadly Insect" => "common",
    "Death Spark" => "uncommon",
    "Disenchant" => "common",
    "Drift of the Dead" => "uncommon",
    "Essence Flare" => "common",
    "Forest" => "basic",
    "Gangrenous Zombies" => "common",
    "Giant Trap Door Spider" => "uncommon",
    "Gorilla Shaman" => "common",
    "Iceberg" => "uncommon",
    "Incinerate" => "common",
    "Insidious Bookworms" => "common",
    "Island" => "basic",
    "Kjeldoran Dead" => "common",
    "Kjeldoran Elite Guard" => "uncommon",
    "Kjeldoran Home Guard" => "uncommon",
    "Kjeldoran Pride" => "common",
    "Lat-Nam's Legacy" => "common",
    "Legions of Lim-Dûl" => "common",
    "Mistfolk" => "common",
    "Mountain" => "basic",
    "Orcish Healer" => "uncommon",
    "Orcish Lumberjack" => "common",
    "Phantasmal Fiend" => "common",
    "Plains" => "basic",
    "Portent" => "common",
    "Reinforcements" => "common",
    "Scars of the Veteran" => "uncommon",
    "Skull Catapult" => "uncommon",
    "Snow Devil" => "common",
    "Soul Burn" => "common",
    "Storm Elemental" => "uncommon",
    "Swamp" => "basic",
    "Swords to Plowshares" => "uncommon",
    "Tinder Wall" => "common",
    "Viscerid Drone" => "uncommon",
    "Whalebone Glider" => "uncommon",
    "Wings of Aesthir" => "uncommon",
    "Woolly Mammoths" => "common",
    "Zuran Spellcaster" => "common",
  }

  def call
    patch_card do |card|
      next unless card["set_code"] == "cstd"
      card["rarity"] = CSTD_RARITY_MAP.fetch(card["name"])
    end
  end
end

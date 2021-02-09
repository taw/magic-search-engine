class PatchColorshifted < Patch
  PlanarChaosPairs = [
    ["Blood Knight", "Black Knight"],
    ["Bog Serpent", "Sea Serpent"],
    ["Brute Force", "Giant Growth"],
    ["Calciderm", "Blastoderm"],
    ["Damnation", "Wrath of God"],
    ["Dunerider Outlaw", "Whirling Dervish"],
    ["Essence Warden", "Soul Warden"],
    ["Fa'adiyah Seer", "Sindbad"],
    ["Frozen Aether", "Kismet"],
    ["Gaea's Anthem", "Glorious Anthem"],
    ["Gossamer Phantasm", "Skulking Ghost"],
    ["Groundbreaker", "Ball Lightning"],
    ["Harmonize", "Concentrate"],
    ["Healing Leaves", "Healing Salve"],
    ["Hedge Troll", "Sedge Troll"],
    ["Keen Sense", "Curiosity"],
    ["Kor Dirge", "Kor Chant"],
    ["Malach of the Dawn", "Ghost Ship"],
    ["Mana Tithe", "Force Spike"],
    ["Melancholy", "Thirst"],
    ["Merfolk Thaumaturgist", "Dwarven Thaumaturgist"],
    ["Mesa Enchantress", "Verduran Enchantress"],
    ["Molten Firebird", "Ivory Gargoyle"],
    ["Mycologist", "Elvish Farmer"],
    ["Null Profusion", "Recycle"],
    ["Ovinize", "Humble"],
    ["Piracy Charm", "Funeral Charm"],
    ["Porphyry Nodes", "Drop of Honey"],
    ["Primal Plasma", "Primal Clay"],
    ["Prodigal Pyromancer", "Prodigal Sorcerer"],
    ["Pyrohemia", "Pestilence"],
    ["Rathi Trapper", "Benalish Trapper"],
    ["Reckless Wurm", "Arrogant Wurm"],
    ["Revered Dead", "Drudge Skeletons"],
    ["Riptide Pilferer", "Headhunter"],
    ["Seal of Primordium", "Seal of Cleansing"],
    ["Serendib Sorcerer", "Sorceress Queen"],
    ["Serra Sphinx", "Serra Angel"],
    ["Shivan Wumpus", "Argothian Wurm"],
    ["Shrouded Lore", "Forgotten Lore"],
    ["Simian Spirit Guide", "Elvish Spirit Guide"],
    ["Sinew Sliver", "Muscle Sliver"],
    ["Skirk Shaman", "Severed Legion"],
    ["Sunlance", "Strafe"],
    ["Vampiric Link", "Spirit Link"],
  ]

  def call
    map = (PlanarChaosPairs + PlanarChaosPairs.map(&:reverse)).to_h
    raise unless map.size == 45*2
    hits = Set[]
    each_printing do |printing|
      name = printing["name"]
      if map[name]
        hits << name
        printing["related"] ||= []
        printing["related"] << map[name]
        printing["related"] = printing["related"].sort
      end
    end
    raise "Bad names on the list of pairs" unless hits == map.keys.to_set
  end
end

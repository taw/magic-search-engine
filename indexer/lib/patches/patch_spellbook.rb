# Should spellbook link to just the front part or to both parts?
class PatchSpellbook < Patch
  def call
    # mtgjson bug
    # https://github.com/mtgjson/mtgjson/issues/1100
    the_hourglass_coven_spellbook = [
      "Hag of Ceaseless Torment",
      "Hag of Dark Duress",
      "Hag of Death's Legion",
      "Hag of Inner Weakness",
      "Hag of Mage's Doom",
      "Hag of Noxious Nightmares",
      "Hag of Scoured Thoughts",
      "Hag of Syphoned Breath",
      "Hag of Twisted Visions",
    ]

    in_spellbook = {}

    each_printing do |printing|
      name = printing["name"]
      spellbook = printing.dig("relatedCards", "spellbook")
      # bugfix:
      if name == "The Hourglass Coven"
        spellbook = the_hourglass_coven_spellbook
      end
      next unless spellbook
      spellbook = spellbook.flat_map{|n| n.split(" // ") }.sort
      printing["spellbook"] = spellbook
      spellbook.each do |other|
        in_spellbook[other] ||= Set[]
        in_spellbook[other] << name
      end
    end

    each_printing do |printing|
      name = printing["name"]
      next unless in_spellbook[name]
      printing["in_spellbook"] = in_spellbook[name].sort
    end
  end
end

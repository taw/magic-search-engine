# This is apparently real, but mtgjson has no other side
# http://i.tcgplayer.com/100595_200w.jpg

class PatchDeleteIncompleteCards < Patch
  def call
    incomplete_cards = [
      "Chandra, Fire of Kaladesh",
      "Jace, Vryn's Prodigy",
      "Kytheon, Hero of Akros",
      "Liliana, Heretical Healer",
      "Nissa, Vastwood Seer",
    ]

    incomplete_cards.each do |name|
      @cards[name].delete_if{|printing| printing["set_code"] == "ptc"}
    end
  end
end

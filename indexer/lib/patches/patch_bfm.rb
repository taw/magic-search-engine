# This gets called after normalization
# so power/toughness/colors need to be already normalized
class PatchBfm < Patch
  def call
    each_printing do |card|
      next unless card["name"] == "B.F.M. (Big Furry Monster)" or card["name"] == "B.F.M. (Big Furry Monster, Right Side)"
      card["text"] = "You must play both B.F.M. cards to put B.F.M. into play. If either B.F.M. card leaves play, sacrifice the other.\nB.F.M. can be blocked only by three or more creatures."
      card["cmc"] = 15
      card["power"] = 99
      card["toughness"] = 99
      card["manaCost"] = "{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}"
      card["types"] = ["Creature"]
      card["subtypes"] = ["The-Biggest-Baddest-Nastiest-Scariest-Creature-You'll-Ever-See"]
      card["colors"] = "b"
      # 28a / 29b -> 28 / 29
      card["number"] = card["number"].sub(/[ab]\z/, "")
      card["layout"] = "normal" # not really

      # Printing data
      card["flavor"] = %Q["It was big. Really, really big. No, bigger than that. Even bigger. Keep going. More. No, more. Look, we're talking krakens and dreadnoughts for jewelry. It was big"\n-Arna Kennerd, skyknight]
    end
  end
end

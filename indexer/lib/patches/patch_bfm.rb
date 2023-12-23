# This gets called after normalization
# so power/toughness/colors need to be already normalized
class PatchBfm < Patch
  def call
    if @cards["B.F.M. (Big Furry Monster) (b)"]
      rename_cards_v4
    else
      rename_cards_v5
    end

    make_sides_same
  end

  def rename_cards_v4
    rename "B.F.M. (Big Furry Monster) (b)", "B.F.M. (Big Furry Monster, Right Side)"
  end

  def rename_cards_v5
    @cards["B.F.M. (Big Furry Monster)"].each do |card|
      if card["number"] == "29"
        rename_printing card, "B.F.M. (Big Furry Monster, Right Side)"
      end
    end
  end

  def make_sides_same
    each_printing do |card|
      case card["name"]
      when "B.F.M. (Big Furry Monster)"
      when "B.F.M. (Big Furry Monster, Right Side)"
      else
        next
      end

      card["names"] = [
        "B.F.M. (Big Furry Monster)",
        "B.F.M. (Big Furry Monster, Right Side)",
      ]
      card["text"] = "You must play both B.F.M. cards to put B.F.M. into play. If either B.F.M. card leaves play, sacrifice the other.\nB.F.M. can be blocked only by three or more creatures."
      card["cmc"] = 15
      card["power"] = 99
      card["toughness"] = 99
      card["mana"] = "{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}"
      card["types"] = ["Creature"]
      card["subtypes"] = ["The-Biggest-Baddest-Nastiest-Scariest-Creature-You'll-Ever-See"]
      card["colors"] = "b"
      # 28a / 29b -> 28 / 29
      # card["number"] = card["number"].sub(/[ab]\z/, "")
      card["layout"] = "normal" # not really

      # Printing data
      card["flavor"] = %["It was big. Really, really big. No, bigger than that. Even bigger. Keep going. More. No, more. Look, we're talking krakens and dreadnoughts for jewelry. It was big"\n-Arna Kennerd, skyknight]
    end
  end
end

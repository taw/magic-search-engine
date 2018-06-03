class PatchBfm < Patch
  def call
    patch_card do |card|
      next unless card["name"] == "B.F.M. (Big Furry Monster)" or card["name"] == "B.F.M. (Big Furry Monster, Right Side)"
      card["text"] = "You must play both B.F.M. cards to put B.F.M. into play. If either B.F.M. card leaves play, sacrifice the other.\nB.F.M. can be blocked only by three or more creatures."
      card["cmc"] = 15
      card["power"] = "99"
      card["toughness"] = "99"
      card["manaCost"] = "{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}{B}"
      card["types"] = ["Creature"]
      card["subtypes"] = ["The-Biggest-Baddest-Nastiest-Scariest-Creature-You'll-Ever-See"]
      card["colors"] = ["Black"]
      # 28a / 29b -> 28 / 29
      card["number"] = card["number"].sub(/[ab]\z/, "")
      card["layout"] = "normal" # not really
    end
  end
end

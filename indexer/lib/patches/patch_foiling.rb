class PatchFoiling < Patch
  # FIXME:
  # Deck index is separate, so we currently can't specify anything useful for precons
  # and DeckDatabase needs to check it. This should change.

  # It's all based on manual research, so mistakes are possible.
  def call
    each_printing do |card|
      if card["set_code"] == "m19" and card["name"] == "Nexus of Fate"
        card["foiling"] = "foilonly"
      elsif card["set_code"] == "dom" and card["name"] == "Firesong and Sunspeaker"
        card["foiling"] = "foilonly"
      elsif card["set_code"] == "ori" and card["number"].to_i >= 273
        # Deck Builder's Toolkit (Magic Origins Edition)
        card["foiling"] = "nonfoil"
      elsif card["set_code"] == "uh" and card["name"] == "Super Secret Tech"
        card["foiling"] = "foilonly"
      elsif card["set_code"] == "cn2" and card["name"] == "Kaya, Ghost Assassin"
        if card["number"] == "75"
          card["foiling"] = "nonfoil"
        else
          card["foiling"] = "foilonly"
        end
      elsif card["set_code"] == "pch" and card["name"] == "Tazeem"
        card["foiling"] = "nonfoil"
      elsif card["set_code"] == "pc2" and card["name"] == "Stairs to Infinity"
        card["foiling"] = "nonfoil"
      elsif card["set_code"] == "pca" and card["types"].include?("Plane")
        card["foiling"] = "nonfoil"
      end
    end

    each_set do |set|
      foiling = case set["code"]
      when "cm1", "15ann", "sus", "sum", "wpn", "thgt", "gpx", "wmcq", "hho", "mlp", "jr", "pro", "gtw"
        "foilonly"
      when "ced", "cedi", "ch", "guru", "apac", "drc", "euro", "dcilm", "ugin", "uqc"
        "nonfoil"
      when "ug"
        "nonfoil"
      when "uh", "cn2"
        "both"
        # with exceptions
      when "ust", "tsts", "cns"
        "both"
      when "e02", "w16", "w17", "rqs", "itp", "cstd"
        "precon"
      when "cp1", "cp2", "cp3"
        "foilonly"
      when "po", "po2", "p3k", "pot"
        "nonfoil"
      when "mgbc", "cstd"
        # Not really working, investigate later
        next
      end

      foiling ||= case set["type"]
      when "core", "expansion"
        if set["release_date"] < "1999-02-15"
          "nonfoil"
        else
          "booster_both"
        end
      when "masters", "spellbook", "two-headed giant", "reprint"
        "both"
      when "from the vault", "premium deck", "masterpiece"
        "foilonly"
      when "duel deck", "global series", "commander", "box", "planechase", "archenemy"
        "precon"
      else
        warn "No idea what's foiling for #{set["name"]} / #{set["code"]} / #{set["type"]}"
        nil
      end

      set["foiling"] = foiling
    end
  end
end

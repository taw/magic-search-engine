class PatchFoiling < Patch
  # FIXME:
  # Deck index is separate, so we currently can't specify anything useful for precons
  # and DeckDatabase needs to check it. This should change.

  # It's all based on manual research, so mistakes are possible.
  def call
    each_set do |set|
      foiling = case set["code"]
      when "cm1", "15ann", "sus"
        "foilonly"
      when "ced", "cedi", "ch", "guru", "apac", "drc", "euro"
        "nonfoil"
      when "ug"
        "nonfoil"
      when "uh"
        # Super-Secret Tech is foil only
      when "ust", "tsts"
        "both"
      when "e02", "w16", "w17", "rqs", "itp"
        "precon"
      when "cp1", "cp2", "cp3"
        "foilonly"
      when "po", "po2", "p3k"
        "nonfoil"
      when "mgbc", "cstd", "e01"
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
      when "duel deck", "global series", "commander", "box"
        "precon"
      else
        warn "No idea what's foiling for #{set["name"]} / #{set["code"]} / #{set["type"]}"
        nil
      end

      set["foiling"] = foiling
    end
  end
end

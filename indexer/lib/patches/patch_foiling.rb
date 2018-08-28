class PatchFoiling < Patch
  # FIXME:
  # Deck index is separate, so we currently can't specify anything useful for precons
  # This should change

  def call
    each_set do |set|
      foiling = case set["code"]
      when "cm1"
        # commander
        "foilonly"
      when "ced", "cedi", "ch"
        # reprint
        "nonfoil"
      when "ug"
        "nonfoil"
      when "uh"
        # Super-Secret Tech is foil only
      when "ust"
        "both"
      when "e02"
        "precon"
      when "mgbc", "cstd", "rqs", "e01"
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

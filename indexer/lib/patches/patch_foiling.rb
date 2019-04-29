class PatchFoiling < Patch
  # FIXME:
  # Deck index is separate, so we currently can't specify anything useful for precons
  # and DeckDatabase needs to check it. This should change.

  # It's all based on manual research, so mistakes are possible.
  def call
    each_printing do |card|
      name = card["name"]
      set_code = card["set_code"]
      types = card["types"]
      number = card["number"]

      if set_code == "m19" and name == "Nexus of Fate"
        card["foiling"] = "foilonly"
      elsif set_code == "dom" and name == "Firesong and Sunspeaker"
        card["foiling"] = "foilonly"
      elsif set_code == "grn" and name == "Impervious Greatwurm"
        card["foiling"] = "foilonly"
      elsif set_code == "grn" and name == "Plains"
        card["foiling"] = "nonfoil"
      elsif set_code == "rna" and name == "The Haunt of Hightower"
        card["foiling"] = "foilonly"
      elsif set_code == "rna" and name == "Swamp"
        card["foiling"] = "nonfoil"
      elsif set_code == "war" and name == "Tezzeret, Master of the Bridge"
        card["foiling"] = "foilonly"
      elsif set_code == "ori" and number.to_i >= 273
        # Deck Builder's Toolkit (Magic Origins Edition)
        card["foiling"] = "nonfoil"
      elsif set_code == "akh"
        # There's boosters, precons, and also Deck Builder's Toolkit
        # These are Deck Builder's Toolkit only
        if ["Forsaken Sanctuary", "Meandering River", "Timber Gorge", "Tranquil Expanse"].include?(name)
          card["foiling"] = "nonfoil"
        end
      elsif set_code == "unh" and name == "Super Secret Tech"
        card["foiling"] = "foilonly"
      elsif set_code == "cn2" and name == "Kaya, Ghost Assassin"
        if number == "75"
          card["foiling"] = "nonfoil"
        else
          card["foiling"] = "foilonly"
        end
      elsif set_code == "hop" and name == "Tazeem"
        card["foiling"] = "nonfoil"
      elsif set_code == "pc2" and name == "Stairs to Infinity"
        card["foiling"] = "nonfoil"
      elsif set_code == "pca" and types.include?("Plane")
        card["foiling"] = "nonfoil"
      elsif set_code == "ppre"
        if ["Dirtcowl Wurm", "Revenant", "Monstrous Hound"].include?(name)
          card["foiling"] = "nonfoil"
        end
      elsif set_code == "s00"
        if name == "Rhox"
          card["foiling"] = "foilonly"
        elsif ["Armored Pegasus", "Python", "Spined Wurm", "Stone Rain"].include?(name)
          card["foiling"] = "nonfoil"
        end
      end
    end

    each_set do |set|
      foiling = case set["code"]
      when "cm1", "p15a", "psus", "psum", "pwpn", "p2hg", "pgpx", "pwcq", "hho", "plpa", "pjgp", "ppro", "pgtw", "pwor", "prel", "pfnm", "pwos", "ppre"
        "foilonly"
      when "ced", "cei", "chr", "pgru", "palp", "pdrc", "pelp", "plgm", "ugin", "pcel", "van", "s99", "mgb"
        "nonfoil"
      when "ugl"
        "nonfoil"
      when "unh", "cn2"
        "both"
      when "ust", "tsb", "cns"
        "both"
      when "e02", "w16", "w17", "rqs", "itp", "cst", "s00", "gk1"
        "precon"
      when "cp1", "cp2", "cp3"
        "foilonly"
      when "por", "p02", "ptk", "ppod"
        "nonfoil"
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

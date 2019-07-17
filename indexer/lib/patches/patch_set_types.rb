class PatchSetTypes < Patch
  def call
    each_set do |set|
      set_code = set["code"]
      main_set_type = set.delete("type").gsub("_", " ")
      set_types = [main_set_type]

      case set_code
      when "bbd"
        set_types << "two-headed giant" << "multiplayer"
      when "mh1"
        set_types << "modern"
      when "cns", "cn2"
        set_types << "conspiracy" << "multiplayer"
      when "cp1", "cp2", "cp3"
        set_types << "deck"
      when "ptk", "por", "p02", "s99"
        set_types << "booster"
      when "s00", "w16", "itp", "cm1"
        set_types << "fixed"
      when "ugl", "unh", "ust"
        set_types << "un"
      when "tpr"
        set_types << "masters"
      end

      if set["name"] =~ /Welcome Deck/
        set_types << "standard"
      end

      case main_set_type
      when "core", "expansion"
        set_types << "standard"
      end

      case main_set_type
      when "archenemy", "commander", "conspiracy", "planechase", "vanguard", "multiplayer", "two-headed giant"
        set_types << "multiplayer"
      end

      case main_set_type
      when "from the vault", "vanguard"
        set_types << "fixed"
      end

      # st:booster is based on having boosters not on inference
      # (included in other boosters too?)
      if set["has_boosters"] or set["in_other_boosters"]
        set_types << "booster"
      end

      case main_set_type
      when "archenemy", "duel deck", "premium deck", "planechase", "box", "deck"
        set_types << "deck"
      when "commander"
        set_types << "deck" unless set_code == "cm1"
      end

      set["types"] = set_types.sort
    end
  end
end

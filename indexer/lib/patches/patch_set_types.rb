# This whole list is a mess
# Maybe I should drop it and trust mtgjson,
# but I actually rely on these set types for a lot of logic

class PatchSetTypes < Patch
  def call
    each_set do |set|
      set_code = set["code"]
      main_set_type = set.delete("type").tr("_", " ")

      main_set_type = "alchemy" if set_code == "ymkm" # mtgjson bug

      set_types = [main_set_type]

      if set["custom"]
        set_types << "custom"
      end

      if set_types.include?("promos")
        set_types = set_types - ["promos"] + ["promo"]
      end

      case set_code
      when "jmp", "j21", "j22", "ajmp"
        set_types << "jumpstart"
      when "bbd"
        set_types << "two-headed giant" << "multiplayer"
      when /\Amh\d\z/, "ltr", "acr"
        set_types << "modern"
      when "h2r"
        # mtgjson bug: it has it as expansion
        main_set_type = "modern"
        set_types = ["promo", "modern"]
      when "cns", "cn2"
        set_types << "conspiracy" << "multiplayer"
      when "cp1", "cp2", "cp3"
        set_types << "deck"
      when "por", "p02", "ptk"
        set_types << "portal" << "booster"
      when "s99"
        set_types << "booster"
      when "s00", "w16", "itp", "cm1"
        set_types << "fixed"
      when "ugl", "unh", "ust", "unf"
        set_types << "un"
      when "tpr"
        set_types << "masters"
      when "md1"
        set_types << "modern"
      when "ocmd", /\Aoc\d\d\z/, "cmr", "clb", "cmm", "who"
        set_types << "commander" << "multiplayer"
      when "pwpn", /\Apwp\d+\z/
        set_types << "wpn"
      when "parl", /\Apal\d+\z/
        set_types << "arena league"
      when "jgp", /\A[gj]\d\d\z/
        set_types << "judge gift"
      when "pdtp", /\Apdp\d\d\z/
        set_types << "duels"
      when /\Apmps\d\d\z/
        set_types << "premiere shop"
      when "mpr", /\Ap0[3-9]\z/, /\Ap[1-9]\d\z/
        set_types << "player rewards"
      when "pgtw", /\Apg\d\d\z/
        set_types << "gateway"
      when "fnm", /\Af\d\d\z/, "pdom", "pgrn", "pm19", "prna", "pwar"
        set_types << "fnm" << "promo"
      when "q06", "q08"
        set_types << "pioneer"
      when "scd"
        set_types = ["box", "commander"]
      when "phed"
        # OK, technically this is Commander deck, but I really don't want to deal with it
        set_types = ["box", "promo", "commander"]
      when "sld", "slc", "slu"
        set_types << "promo" << "sld"
      when "past"
        set_types << "shandalar"
      when /\Aps\d\d\z/, "psdc"
        set_types << "promo" << "box" << "sdcc"
      when "pz2", /\Ap...\z/
        set_types << "promo"
      when /\Ass\d/
        set_types << "spellbook" << "box"
      when "clu"
        set_types << "box" << "booster"
      end

      # Some of these are not actually funny sets, just promo sets mixing funny and regular cards (like plst)
      # sch is here only due to spoiled Moonshaker Cavalry with incorrect date, remove it past WOE (or in 2024)
      funny_sets = %W[unh ugl pcel hho parl prel ust pust ppc1 htr htr16 htr17 htr18 htr19 htr20 pal04 h17 j17 tbth tdag tfth thp1 thp2 thp3 ptg cmb1 cmb2 htr18 und punh plst o90p olep p30a ulst phtr ph17 ph18 ph19 ph20 ph21 ph22 p30m sch mb2 da1]
      if funny_sets.include?(set_code)
        set_types << "funny"
        set["funny"] = true
      end

      if set["name"] =~ /Welcome Deck/ or set["name"] == "M19 Gift Pack"
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
        set_types << "deck" unless %w[ha1 ha2 ha3 ha4 ha5 ha6 ha7].include?(set_code)
      when "commander"
        set_types << "deck" unless %w[cm1 cc1 cc2].include?(set_code)
      when "arsenal"
        set_types << "commander" << "multiplayer"
      end

      set["types"] = set_types.sort.uniq
    end
  end
end

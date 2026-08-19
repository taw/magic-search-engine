# This whole list is a mess
# Maybe I should drop it and trust mtgjson,
# but I actually rely on these set types for a lot of logic

class PatchSetTypes < Patch
  def boosters_root
    Indexer::ROOT + "boosters"
  end

  def has_own_boosters?(set_code)
    boosters_root.glob("#{set_code}.yaml").any? or
      boosters_root.glob("#{set_code}-*.yaml").any?
  end

  def call
    each_set do |set|
      set_code = set["code"]

      main_set_type = set.delete("type").tr("_", " ")

      # These overrides are very questionable
      main_set_type = "box" if set_code == "aa1"
      main_set_type = "box" if set_code == "aa2"
      main_set_type = "alchemy" if set_code =~ /\Aom[b1-9]\z/

      # Only legal in Commander, Legacy, and Vintage
      main_set_type = "eternal" if set_code == "mar" or set_code == "spe"

      set_types = [main_set_type]

      if set["custom"]
        set_types << "custom"
      end

      case set_code
      # early jXX are Judge Gift cards, late jXX are Jumpstarts, so no regexp here
      when "jmp", "j21", "j22", "ajmp", "j25"
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
      when "pdtp", /\Apdp\d\d\z/
        set_types << "duels"
      when "pdom", "pgrn", "pm19", "prna", "pwar"
        set_types << "fnm"
      when "q06", "q08"
        set_types << "pioneer"
      when "scd"
        set_types = ["box", "commander"]
      when "sld", "slc", "slu"
        set_types << "promo" << "sld"
      when "past"
        set_types << "shandalar"
      when "pz2", /\Ap...\z/
        set_types << "promo"
      when /\Ass\d/
        set_types << "spellbook" << "box"
      when "clu"
        set_types << "box" << "booster"
      when "tmc"
        set_types << "commander" << "multiplayer"
      end

      # mtgjson keeps reshuffling set codes for these promo series,
      # but the names are stable, so match on them instead
      case set["name"]
      when /\AJudge Gift Cards /
        set_types << "judge gift"
      when /\AMagic Player Rewards /
        set_types << "player rewards"
      when /\AArena League /
        set_types << "arena league"
      when /\AMagic Premiere Shop /
        set_types << "premiere shop"
      when /\AFriday Night Magic /
        set_types << "fnm"
      when /\AWizards Play Network /
        set_types << "wpn"
      when /\ASan Diego Comic-Con /
        set_types << "box" << "sdcc"
      end

      # Some of these still mix in regular cards (basics in un-sets, reprints in mb2),
      # so PatchFunny decides card by card.
      # Promo sets which only mix in a few funny cards are not funny sets at all -
      # they live in PatchFunny::SetsWithSomeFunnyCards instead.
      #
      # mbc is on neither list. It is legal in Commander, Legacy, and Vintage, and its only
      # non-legal cards are the Alchemy conversions, which the acorn stamp already catches.
      #
      # The Theros Hero's Path decks (thp1 thp2 thp3) and challenge decks (tbth tfth tdag)
      # used to be here. Nothing about them is funny - they were only ever on this list to
      # keep them out of formats, which PatchSpecialFormat now does for the right reason.
      funny_sets = %W[unh ugl pcel hho ust pust ppc1 h17 ptg cmb1 cmb2 und punh ulst mb2 unk punk past]
      if funny_sets.include?(set_code) or set["name"] =~ /Heroes of the Realm/
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

      # st:booster is based on the set having its own boosters, not on inference
      if has_own_boosters?(set_code)
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

      # Mostly there to drive specs
      if set["partial_preview"]
        # if it's already released, clear the flag and accept the consequences
        # mtgjson is sometimes slow to clear this flag
        # We could even add a buffer here so we do format rotation in good time
        if Date.parse(set["release_date"]) > Date.today
          set_types << "preview"
        end
      end

      set["types"] = set_types.sort.uniq
    end
  end
end

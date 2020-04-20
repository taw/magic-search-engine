describe "Foils" do
  include_context "db"

  let(:urza_legacy_release_date) { Date.parse("1999-02-15") }

  def assert_foiling(cards, foiling)
    cards.each do |c|
      c.foiling.should eq(foiling), "#{c.set_code} #{c.name} #{c.number} got:#{c.foiling} expected:#{foiling}"
    end
  end

  def assert_foiling_partial_precon(cards)
    cards.each do |card|
      name = card.name
      if card.set.cards_in_precons
        nonfoils, foils = card.set.cards_in_precons
        has_nonfoil = nonfoils.include?(name)
        has_foil = foils.include?(name)

        if has_foil and not has_nonfoil
          card.foiling.should eq("foilonly"), "#{card} should be foilonly"
        elsif has_nonfoil and not has_foil
          card.foiling.should eq("nonfoil"), "#{card} should be nonfoil"
        elsif has_nonfoil and has_foil
          if card.set.code == "dkm"
            # it's totally fine
          else
            card.foiling.should eq("totally broken"), "#{card} is marked as both foil and nonfoil, that is wrong for precon cards generally"
          end
        else
          card.foiling.should eq("totally broken"), "#{card} expected in precons but missing"
        end
      else
        card.foiling.should eq("totally broken"), "#{card} expected in precons but that set has no precons"
      end
    end
  end

  def assert_by_type(set)
    if !(set.types & ["core", "expansion"]).empty?
      booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
      if set.release_date >= urza_legacy_release_date
        assert_foiling(booster_cards, "both")
      else
        assert_foiling(booster_cards, "nonfoil")
      end
      assert_foiling_partial_precon(extra_cards)
    elsif !(set.types & ["masters", "spellbook", "reprint", "two-headed giant"]).empty?
      assert_foiling(set.printings, "both")
    elsif !(set.types & ["from the vault", "masterpiece", "premium deck"]).empty?
      assert_foiling(set.printings, "foilonly")
    elsif !(set.types & ["commander", "duel deck", "archenemy", "global series", "box", "board game deck", "planechase", "archenemy"]).empty?
      if set.decks.empty?
        warn "Expected a deck for this product: #{set.code} #{set.name}"
      else
        assert_foiling_partial_precon(set.printings)
      end
    elsif !(set.types & ["treasure chest"]).empty?
      # does it really matter for non-paper?
    else
      warn "No idea about #{set.name} / #{set.types.join(" / ")}"
    end
  end

  it do
    # We're only interested in booster and precon sets
    # as that can mess up with other site functionality
    # For promo sets, just trust mtgjson without verifying anything
    db.sets.each do |set_code, set|
      next if set.types.include?("promo")
      next if set.types.include?("memorabilia")
      next if set.types.include?("token")

      case set.code
      when "g17", "g18", "fmb1"
        assert_foiling(set.printings, "foilonly")
      when "phuk", "arn", "mir", "drk", "atq", "4ed"
        assert_foiling(set.printings, "nonfoil")
      when "ced", "cei", "chr", "ugl", "pelp", "pgru", "palp", "por", "p02", "ptk", "pdrc", "plgm", "ppod", "ugin", "pcel", "van", "s99", "mgb"
        assert_foiling(set.printings, "nonfoil")
      when "ust", "tsb", "cns", "soi"
        assert_foiling(set.printings, "both")
      when "cm1", "p15a", "psus", "psum", "pwpn", "p2hg", "pgpx", "pwcq", "plpa", "pjgp", "ppro", "pgtw", "pwor", "pwos", "prel", "pfnm"
        assert_foiling(set.printings, "foilonly")
      when "w16", "w17", "cp1", "cp2", "cp3", "cst", "itp", "gk1", "gk2", "btd", "dkm", "cma"
        assert_foiling_partial_precon(set.printings)
      when "s00"
        promo, rest = set.printings.partition{|c| c.name == "Rhox"}
        sampler, regular = rest.partition{|c| ["Armored Pegasus", "Python", "Spined Wurm", "Stone Rain"].include?(c.name) }
        assert_foiling_partial_precon(regular)
        assert_foiling(promo, "foilonly")
        assert_foiling(sampler, "nonfoil")
      when "ody"
        promo, rest = set.printings.partition{|c| c.number == "325†"}
        assert_foiling(promo, "foilonly")
        assert_foiling(rest, "both")
      when "pls", "shm", "10e"
        foil_alt_art, regular_cards = set.printings.partition{|c| !!(c.number =~ /★|†/) }
        foil_alt_art_names = foil_alt_art.map(&:name).to_set
        has_foil_alt_art, regular_cards = regular_cards.partition{|c| foil_alt_art_names.include?(c.name) }
        assert_foiling(foil_alt_art, "foilonly")
        assert_foiling(has_foil_alt_art, "nonfoil")
        assert_foiling(regular_cards, "both")
      when "unh"
        foil_alt_art, regular_cards = set.printings.partition{|c| c.name == "Super Secret Tech" or c.number =~ /★/ }
        foil_alt_art_names = foil_alt_art.map(&:name).to_set
        has_foil_alt_art, regular_cards = regular_cards.partition{|c| foil_alt_art_names.include?(c.name) }
        assert_foiling(foil_alt_art, "foilonly")
        assert_foiling(has_foil_alt_art, "nonfoil")
        assert_foiling(regular_cards, "both")
      when "m15", "ori"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        assert_foiling(booster_cards, "both")
        assert_foiling(extra_cards, "nonfoil")
      when "dom"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        buy_a_box_promo = extra_cards.find{|c| c.name == "Firesong and Sunspeaker"}
        assert_foiling(booster_cards, "both")
        assert_foiling_partial_precon(extra_cards - [buy_a_box_promo])
        assert_foiling([buy_a_box_promo], "foilonly")
      when "m19"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        buy_a_box_promo = extra_cards.find{|c| c.name == "Nexus of Fate"}
        assert_foiling(booster_cards, "both")
        assert_foiling_partial_precon(extra_cards - [buy_a_box_promo])
        assert_foiling([buy_a_box_promo], "foilonly")
      when "m20"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        misprint = extra_cards.select{|c| c.number =~ /†/}
        buy_a_box_promo = extra_cards.find{|c| c.name == "Rienne, Angel of Rebirth"}
        assert_foiling(booster_cards, "both")
        assert_foiling([buy_a_box_promo], "foilonly")
        assert_foiling(misprint, "both")
      when "iko"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        assert_foiling(booster_cards, "both")
      when "eld"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        buy_a_box_promo = extra_cards.find{|c| c.name == "Kenrith, the Returned King"}
        assert_foiling(booster_cards, "both")
        # Some but not all of them appear in collector boosters too:
        # assert_foiling_partial_precon(extra_cards - [buy_a_box_promo])
        # Apparently it's available nonfoil in the $450 product
        assert_foiling([buy_a_box_promo], "both")
      when "thb"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        buy_a_box_promo = extra_cards.find{|c| c.name == "Athreos, Shroud-Veiled"}
        assert_foiling(booster_cards, "both")
        # Some but not all of them appear in collector boosters too:
        # assert_foiling_partial_precon(extra_cards - [buy_a_box_promo])
        assert_foiling([buy_a_box_promo], "both")
      when "war"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        buy_a_box_promo = extra_cards.find{|c| c.name == "Tezzeret, Master of the Bridge"}
        japanese_alt_art = extra_cards.select{|c| c.number =~ /★/}
        assert_foiling(booster_cards, "both")
        assert_foiling(japanese_alt_art, "both")
        assert_foiling_partial_precon(extra_cards - [buy_a_box_promo, *japanese_alt_art])
        assert_foiling([buy_a_box_promo], "foilonly")
      when "grn"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        buy_a_box_promo = extra_cards.find{|c| c.name == "Impervious Greatwurm"}
        basics = extra_cards.select{|c| c.types.include?("basic") }
        assert_foiling(booster_cards, "both")
        assert_foiling_partial_precon(extra_cards - [buy_a_box_promo, *basics])
        assert_foiling([buy_a_box_promo], "foilonly")
        assert_foiling(basics, "both")
      when "rna"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        buy_a_box_promo = extra_cards.find{|c| c.name == "The Haunt of Hightower"}
        basics = extra_cards.select{|c| c.types.include?("basic") }
        assert_foiling(booster_cards, "both")
        assert_foiling_partial_precon(extra_cards - [buy_a_box_promo, *basics])
        assert_foiling([buy_a_box_promo], "foilonly")
        assert_foiling(basics, "both")
      when "mh1"
        special, regular = set.printings.partition{|c| c.name == "Flusterstorm"}
        assert_foiling(regular, "both")
        assert_foiling(special, "nonfoil")
      when "cn2"
        special, regular = set.printings.partition{|c| c.name == "Kaya, Ghost Assassin"}
        assert_foiling(regular, "both")
        normal_kaya, foil_kaya = special.sort_by{|c| c.number.to_i}
        assert_foiling([normal_kaya], "nonfoil")
        assert_foiling([foil_kaya], "foilonly")
      when "bbd"
        special, regular = set.printings.partition{|c| c.name == "Rowan Kenrith" or c.name == "Will Kenrith"}
        assert_foiling(regular, "both")
        kenriths = special.sort_by{|c| c.number.to_i}
        assert_foiling(kenriths[0,2], "nonfoil")
        assert_foiling(kenriths[2,2], "foilonly")
      when "hop"
        promo, rest = set.printings.partition{|c| c.name == "Tazeem" }
        assert_foiling(promo, "nonfoil")
        assert_foiling_partial_precon(rest)
      when "pc2"
        promo, rest = set.printings.partition{|c| c.name == "Stairs to Infinity" }
        assert_foiling(promo, "nonfoil")
        assert_foiling_partial_precon(rest)
      when "pca", "oe01", "oarc", "ohop", "opc2"
        assert_foiling_partial_precon(set.printings)
      when "opca", "parc"
        assert_foiling(set.printings, "nonfoil")
      when "ppre"
        cards = set.printings.sort_by(&:release_date)
        assert_foiling(cards[0..2], "nonfoil")
        assert_foiling(cards[3..-1], "foilonly")
      when "akh"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        assert_foiling(booster_cards, "both")
        lands, rest = extra_cards.partition{|c| c.types.include?("land") }
        assert_foiling(lands, "nonfoil")
        assert_foiling_partial_precon(rest)
      when "5ed", "6ed"
        assert_foiling(set.printings, "nonfoil")
      when "8ed", "9ed"
        special, regular = set.printings.partition{|c| c.number =~ /\AS/ }
        assert_foiling(special, "nonfoil")
        assert_foiling(regular, "both")
      when "ice"
        assert_foiling(set.printings, "nonfoil")
      else
        assert_by_type(set)
      end
    end
  end
end

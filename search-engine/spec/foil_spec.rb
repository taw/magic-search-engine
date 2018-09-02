describe "Foils" do
  include_context "db"

  let(:urza_legacy_release_date) { Date.parse("1999-02-15") }

  def assert_foiling(cards, foiling)
    cards.each do |c|
      c.foiling.should eq(foiling), "#{c.set_code} #{c.name} got:#{c.foiling} expected:#{foiling}"
    end
  end

  def assert_foiling_precon(set)
    foils, nonfoils = set.decks.flat_map(&:cards_with_sideboard).map(&:last).select{|c| c.set_code == set.code}.partition(&:foil)
    foils = foils.flat_map(&:parts).map(&:name).uniq
    nonfoils = nonfoils.flat_map(&:parts).map(&:name).uniq
    # Actually bad due to variants not present

    set.printings.group_by(&:foiling).each do |category, printings|
      printings = printings.map(&:name).uniq
      if category == "foilonly"
        printings.should match_array foils
      elsif category == "nonfoil"
        binding.pry if printings.to_set != nonfoils.to_set
        printings.should match_array nonfoils
      elsif category == "both"
        warn "Precons should not have both foil and nonfoil of same card [RIGHT???]"
      else
        warn "Unknown foiling #{category} for #{set.name}"
      end
    end
  end

  def assert_foiling_partial_precon(cards)
    cards.each do |card|
      name = card.name
      nonfoils, foils = card.set.cards_in_precons
      has_nonfoil = nonfoils.include?(name)
      has_foil = foils.include?(name)

      if has_foil and not has_nonfoil
        card.foiling.should eq("foilonly"), "#{card} should be foilonly"
      elsif has_nonfoil and not has_foil
        card.foiling.should eq("nonfoil"), "#{card} should be nonfoil"
      elsif has_nonfoil and has_foil
        card.foiling.should eq("totally broken"), "#{card} is marked as both foil and nonfoil, that is wrong for precon cards generally"
      else
        card.foiling.should eq("totally broken"), "#{card} expected in precons but missing"
      end
    end
  end

  def assert_by_type(set)
    case set.type
    when "core", "expansion"
      booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
      if set.release_date >= urza_legacy_release_date
        assert_foiling(booster_cards, "both")
      else
        assert_foiling(booster_cards, "nonfoil")
      end
      assert_foiling_partial_precon(extra_cards)
    when "masters", "spellbook", "reprint", "two-headed giant"
      assert_foiling(set.printings, "both")
    when "from the vault", "masterpiece", "premium deck"
      assert_foiling(set.printings, "foilonly")
    when "commander", "duel deck", "archenemy", "global series", "box", "board game deck", "planechase", "archenemy"
      if set.decks.empty?
        warn "Expected a deck for this product: #{set.name}"
      else
        assert_foiling_precon(set)
      end
    else
      warn "No idea about #{set.name} / #{set.type}"
    end
  end

  it do
    db.sets.each do |set_code, set|
      # Sets without foiling set are all known bad
      unless set.foiling
        warn "Support for #{set.code} #{set.name} not implemented yet"
        next
      end

      case set.code
      when "ced", "cedi", "ch", "ug", "euro", "guru", "apac", "po", "po2", "p3k", "drc", "dcilm", "pot", "ugin"
        assert_foiling(set.printings, "nonfoil")
      when "ust", "tsts", "cns"
        assert_foiling(set.printings, "both")
      when "cm1", "15ann", "sus", "sum", "wpn", "thgt", "gpx", "wmcq"
        assert_foiling(set.printings, "foilonly")
      when "w16", "w17", "cp1", "cp2", "cp3", "cstd", "itp"
        assert_foiling_partial_precon(set.printings)
      when "ori"
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
      else
        assert_by_type(set)
      end
    end
  end
end

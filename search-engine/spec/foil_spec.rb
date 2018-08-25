describe "Foils" do
  include_context "db"

  let(:urza_legacy_release_date) { Date.parse("1999-02-15") }

  def assert_foiling(cards, foiling)
    cards.each do |c|
      c.foiling.should eq(foiling), "#{c.set_code} #{c.name} got:#{c.foiling} expected:#{foiling}"
    end
  end

  def assert_foiling_precon(set)
    foils, nonfoils = set.decks.flat_map(&:cards_with_sideboard).map(&:last).partition(&:foil)
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

  def assert_by_type(set)
    case set.type
    when "core", "expansion"
      booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
      if set.release_date >= urza_legacy_release_date
        assert_foiling(booster_cards, "both")
      else
        assert_foiling(booster_cards, "nonfoil")
      end
      assert_foiling(extra_cards, "unknown_for_nonbooster")
      unless extra_cards.empty?
        warn "Support for nonbooster cards in #{set.code} #{set.name} not implemented yet"
      end
    when "masters", "spellbook", "reprint", "two-headed giant"
      assert_foiling(set.printings, "both")
    when "from the vault", "masterpiece", "premium deck"
      assert_foiling(set.printings, "foilonly")
    when "commander", "duel deck", "archenemy", "global series", "box", "board game deck"
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
      when "ced", "cedi", "ch", "ug"
        assert_foiling(set.printings, "nonfoil")
      when "ust"
        assert_foiling(set.printings, "both")
      when "cm1"
        assert_foiling(set.printings, "foilonly")
      else
        assert_by_type(set)
      end
    end
  end
end

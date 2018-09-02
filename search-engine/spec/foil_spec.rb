describe "Foils" do
  include_context "db"

  let(:urza_legacy_release_date) { Date.parse("1999-02-15") }

  def assert_foiling(cards, foiling)
    cards.each do |c|
      c.foiling.should eq(foiling), "#{c.set_code} #{c.name} got:#{c.foiling} expected:#{foiling}"
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
          card.foiling.should eq("totally broken"), "#{card} is marked as both foil and nonfoil, that is wrong for precon cards generally"
        else
          card.foiling.should eq("totally broken"), "#{card} expected in precons but missing"
        end
      else
        card.foiling.should eq("totally broken"), "#{card} expected in precons but that set has no precons"
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
        assert_foiling_partial_precon(set.printings)
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
      when "ced", "cedi", "ch", "ug", "euro", "guru", "apac", "po", "po2", "p3k", "drc", "dcilm", "pot", "ugin", "uqc", "van"
        assert_foiling(set.printings, "nonfoil")
      when "ust", "tsts", "cns"
        assert_foiling(set.printings, "both")
      when "cm1", "15ann", "sus", "sum", "wpn", "thgt", "gpx", "wmcq", "hho", "mlp", "jr", "pro", "gtw", "wrl", "wotc", "rep", "fnmp"
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
      when "uh"
        special, regular = set.printings.partition{|c| c.name == "Super Secret Tech"}
        assert_foiling(regular, "both")
        assert_foiling(special, "foilonly")
      when "cn2"
        special, regular = set.printings.partition{|c| c.name == "Kaya, Ghost Assassin"}
        assert_foiling(regular, "both")
        normal_kaya, foil_kaya = special.sort_by{|c| c.number.to_i}
        assert_foiling([normal_kaya], "nonfoil")
        assert_foiling([foil_kaya], "foilonly")
      when "pch"
        promo, rest = set.printings.partition{|c| c.name == "Tazeem" }
        assert_foiling(promo, "nonfoil")
        assert_foiling_partial_precon(rest)
      when "pc2"
        promo, rest = set.printings.partition{|c| c.name == "Stairs to Infinity" }
        assert_foiling(promo, "nonfoil")
        assert_foiling_partial_precon(rest)
      when "pca"
        planes, rest = set.printings.partition{|c| c.types.include?("plane") }
        assert_foiling(planes, "nonfoil")
        assert_foiling_partial_precon(rest)
      when "ptc"
        cards = set.printings.sort_by(&:release_date)
        assert_foiling(cards[0..2], "nonfoil")
        assert_foiling(cards[3..-1], "foilonly")
      when "akh"
        booster_cards, extra_cards = set.printings.partition(&:in_boosters?)
        assert_foiling(booster_cards, "both")
        lands, rest = extra_cards.partition{|c| c.types.include?("land") }
        assert_foiling(lands, "nonfoil")
        assert_foiling_partial_precon(rest)
      else
        assert_by_type(set)
      end
    end
  end
end

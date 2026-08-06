describe "Arena and MTGO Boosters" do
  include_context "db"

  let(:boosters) { db.unique_supported_booster_types.values }
  # What about remastered sets?
  let(:arena_boosters) { boosters.select{|b| b.code =~ /arena/} }
  let(:mtgo_boosters) { boosters.select{|b| b.code =~ /\A(tpr|me1|me2|me3|me4|vma)-mtgo\z/ } }
  let(:non_legal_boosters) { boosters.select{|b| b.code == "30a-draft" }}
  let(:non_digital_boosters) { boosters - arena_boosters - mtgo_boosters - non_legal_boosters }

  # mtgjson gives Through the Omenpaths mtgo availability and nothing else, so
  # none of its cards pass is:arena. It is an Arena set as much as an MTGO one:
  # it launched there on 2025-09-23 as the Universes Within Spider-Man, and the
  # 17lands public draft data om1-arena is measured from is Arena only. Drop this
  # once mtgjson lists arena for the set.
  let(:sets_mtgjson_does_not_know_are_on_arena) { Set["om1"] }

  it "Arena boosters contain only Arena cards" do
    arena_boosters.each do |booster|
      not_on_arena = booster.cards.reject do |card|
        card.arena? or sets_mtgjson_does_not_know_are_on_arena.include?(card.set_code)
      end
      not_on_arena.should(eq([]), "All cards for #{booster.code} #{booster.name} should be Arena cards")
    end
  end

  it "Arena boosters contain no foils" do
    arena_boosters.each do |booster|
      booster.foil_cards.should(eq([]), "No cards for #{booster.code} #{booster.name} should be foil, Arena has no foils")
    end
  end

  # "is:baseset" is not usable here - legitimate Arena sheets are routinely outside base set:
  # bonus sheets (wot, brr, sis, spg), Arena-only alt numbering (ktk /y/), extra basics (lci 393-402).
  # Plain "promo:boosterfun" is not usable either - mtgjson marks whole bonus sheets as boosterfun
  # (all of wot and spg), even though those are the only printings of those cards.
  # So what we check is that we never take an alternative printing when a plain one exists in same set.
  it "Arena boosters contain only base printings, no boosterfun variants" do
    arena_boosters.each do |booster|
      variants = booster.cards.map(&:main_front).select do |printing|
        boosterfun?(printing) and printing.card.printings.any?{|other|
          other.set_code == printing.set_code and !boosterfun?(other)
        }
      end
      variants.should(eq([]), "Cards for #{booster.code} #{booster.name} should be base printings, got: #{variants.map(&:id).join(", ")}")
    end
  end

  it "MTGO exclusive boosters contain only MTGO cards" do
    mtgo_boosters.each do |booster|
      booster.cards.all?(&:mtgo?).should(eq(true), "All cards for #{booster.code} #{booster.name} should be MTGO cards")
    end
  end

  # Most of them are on MTGO as well
  it "Non-digital boosters don't contain any digital exclusive cards" do
    non_digital_boosters.each do |booster|
      booster.cards.all?(&:paper?).should(eq(true), "All cards for #{booster.code} #{booster.name} should be paper cards")
    end
  end

  it "No reversibleback cards are in boosters" do
    # "is:reversiblefront" appear in a few
    assert_search_results "is:booster is:reversibleback"
  end

  def boosterfun?(printing)
    !!printing.promo_types&.include?("boosterfun")
  end
end

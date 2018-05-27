describe "deck: search" do
  include_context "db"

  it "Unique names" do
    assert_search_equal %Q[deck:"Ingenious Machinists" or deck:"Woodland Warriors"], %Q[e:"Elves vs Inventors"]
  end

  it "Case insensitive" do
    assert_search_equal %Q[deck:"Teferi, Timebender"], %Q[deck:"Teferi Timebender"]
    assert_search_equal %Q[deck:"Teferi, Timebender"], %Q[deck:"teferi timebender"]
  end

  it "Partial names" do
    assert_search_equal %Q[deck:"Amonkhet / Gideon"], %Q[deck:"Gideon, Martial Paragon"]
  end

  it "Each deck can be searched by set code and slug" do
    db.decks.each do |deck|
      cond = ConditionDeck.new("#{deck.set_code}/#{deck.slug}")
      cond.resolve_deck_name(db).should eq [deck]
    end
  end

  it "Each deck can be searched by full set name and deck name" do
    db.decks.each do |deck|
      cond = ConditionDeck.new("#{deck.set_name} / #{deck.name}")
      cond.resolve_deck_name(db).should eq [deck]
    end
  end

  it "Each deck can be searched by slug only" do
    db.decks.each do |deck|
      cond = ConditionDeck.new(deck.slug)
      cond.resolve_deck_name(db).should include deck
    end
  end

  it "Each deck can be searched by deck name only" do
    db.decks.each do |deck|
      cond = ConditionDeck.new(deck.name)
      cond.resolve_deck_name(db).should include deck
    end
  end
end

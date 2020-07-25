describe "deck: search" do
  include_context "db"

  let(:decks_by_set) { db.decks.group_by(&:set) }

  it "Unique names" do
    assert_search_equal %Q[deck:"Ingenious Machinists" or deck:"Woodland Warriors"], %Q[e:"Elves vs Inventors"]  end

  it "Case insensitive" do
    assert_search_equal %Q[deck:"Teferi, Timebender"], %Q[deck:"Teferi Timebender"]
    assert_search_equal %Q[deck:"Teferi, Timebender"], %Q[deck:"teferi timebender"]
  end

  it "Partial names" do
    assert_search_equal %Q[deck:"Amonkhet / Gideon"], %Q[deck:"Gideon, Martial Paragon"]
  end

  it "Each deck can be searched by set code and slug" do
    db.decks.each do |deck|
      db.resolve_deck_name("#{deck.set_code}/#{deck.slug}").should eq [deck]
    end
  end

  it "Each deck can be searched by full set name and deck name" do
    db.decks.each do |deck|
      db.resolve_deck_name("#{deck.set_name} / #{deck.name}").should eq [deck]
    end
  end

  it "Each deck can be searched by slug only" do
    db.decks.each do |deck|
      db.resolve_deck_name(deck.slug).should include deck
    end
  end

  it "Each deck can be searched by deck name only" do
    db.decks.each do |deck|
      db.resolve_deck_name(deck.name).should include deck
    end
  end

  it "* matches all decks" do
    db.resolve_deck_name("*").should eq(db.decks)
  end

  it "set_name/* matches all decks in set" do
    decks_by_set.each do |set, decks|
      db.resolve_deck_name("#{set.name}/*").should eq(decks)
    end
  end

  it "set_code/* matches all decks in set" do
    decks_by_set.each do |set, decks|
      db.resolve_deck_name("#{set.code}/*").should eq(decks)
    end
  end

  it "ignores accented characters" do
    assert_search_equal "deck:Šlemr", "deck:Slemr"
    assert_search_equal "deck:ŠLEMR", "deck:šlemr"

    assert_search_equal "deck:Kröger", "deck:Kroger"
    assert_search_equal "deck:KRÖGER", "deck:kroger"

    assert_search_equal "deck:Kühn", "deck:Kühn"
    assert_search_equal "deck:KÜHN", "deck:kühn"

    assert_search_equal "deck:Romão", "deck:Romao"
    assert_search_equal "deck:ROMÃO", "deck:romao"
  end
end

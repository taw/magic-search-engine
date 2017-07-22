describe "Unsets" do
  include_context "db", "ug", "uh", "uqc", "hho"

  it "half power" do
    "pow=1"  .should exclude_cards "Little Girl"
    "pow>0"  .should include_cards "Little Girl"
    "pow=0.5".should include_cards "Little Girl"
    "pow=½"  .should include_cards "Little Girl"
    "pow<1"  .should include_cards "Little Girl"
    "pow=1"  .should exclude_cards "Little Girl"
    "pow>1"  .should exclude_cards "Little Girl"
    "pow=tou".should include_cards "Little Girl"
    "pow=cmc".should include_cards "Little Girl"
  end

  it "half toughness" do
    "tou=1"  .should exclude_cards "Little Girl"
    "tou>0"  .should include_cards "Little Girl"
    "tou=0.5".should include_cards "Little Girl"
    "tou=½"  .should include_cards "Little Girl"
    "tou<1"  .should include_cards "Little Girl"
    "tou=1"  .should exclude_cards "Little Girl"
    "tou>1"  .should exclude_cards "Little Girl"
  end

  it "half cmc" do
    "cmc=1"  .should exclude_cards "Little Girl"
    "cmc>0"  .should include_cards "Little Girl"
    "cmc=0.5".should include_cards "Little Girl"
    "cmc=½"  .should include_cards "Little Girl"
    "cmc<1"  .should include_cards "Little Girl"
    "cmc=1"  .should exclude_cards "Little Girl"
    "cmc>1"  .should exclude_cards "Little Girl"
  end

  it "is:funny" do
    "is:funny"          .should include_cards "Little Girl"
    "is:new"            .should include_cards "Little Girl"
    "is:silver-bordered".should include_cards "Little Girl"
    "not:black-bordered".should include_cards "Little Girl"
    "not:white-bordered".should include_cards "Little Girl"
    "not:funny"         .should return_cards(
      "Forest",
      "Island",
      "Mountain",
      "Plains",
      "Swamp",
    )
    "not:new"           .should include_cards(
      "1996 World Champion",
      "Fraternal Exaltation",
      "Proposal",
      "Shichifukujin Dragon",
      "Splendid Genesis"
    )
    "not:new".should equal_search "-e:uh,hho -(Robot Chicken)"
    "not:silver-bordered".should return_cards(
      "Forest",
      "Mountain",
      "Swamp",
      "Plains",
      "Island",
      "1996 World Champion",
      "Fraternal Exaltation",
      "Proposal",
      "Robot Chicken",
      "Shichifukujin Dragon",
      "Splendid Genesis"
    )
    "is:black-bordered".should return_cards(
      "Forest",
      "Mountain",
      "Swamp",
      "Plains",
      "Island",
      "1996 World Champion",
      "Fraternal Exaltation",
      "Proposal",
      "Robot Chicken",
      "Shichifukujin Dragon",
      "Splendid Genesis"
    )
    "is:white-bordered".should return_no_cards
  end

  # I'm not sure I want this syntax
  # def test_edition_shortcut_syntax
  #   assert_search_equal "e:uh,ug", "e:uh or e:ug"
  #   assert_search_equal "e:uh+ug", "t:basic"
  #   assert_count_results "e:uh,ug", 227
  #   assert_count_results "e:uh,ug -e:ug+ug", 222
  # end

  it "other:" do
    assert_search_results "other:c:g", "What", "Who", "When", "Where"
    # Any other has cmc != 4
    assert_search_results "other:-cmc=4", "Who", "What", "When", "Where", "Why", "Naughty", "Nice"
    # Doesn't have other side with cmc=4
    # This includes Where (cmc=4) and all single-sided cards
    assert_search_include "-other:cmc=4", "Where", "Chicken Egg"
    assert_search_exclude "-other:cmc=4", "What", "Who", "Why", "When"
  end

  it "mana:xyz" do
    assert_search_results "mana>=xyz", "The Ultimate Nightmare of Wizards of the Coast® Customer Service"
    assert_search_results "mana>={x}{z}", "The Ultimate Nightmare of Wizards of the Coast® Customer Service"
  end

  it "mana:{hw}" do
    assert_search_results "mana={hw}", "Little Girl"
    assert_search_equal "mana={hw}{hw}", "mana=w"
    assert_search_equal "mana>{hw}{hw}", "mana>w"
    assert_search_differ "mana>={hw}", "mana>=0"
    assert_search_differ "mana>={hw}", "mana>=w"
    assert_search_equal "mana>{hw}", "mana>=w"
  end

  it "! and weird card names" do
    db.cards.values.each do |card|
      "!#{card.name}".should return_cards(card.name)
    end
  end

  it "name search and weird card names" do
    db.cards.values.each do |card|
      # Sadly "Not" doesn't work because it's magic keyword
      # Maybe that's worth fixing
      next if card.name == "Erase (Not the Urza's Legacy One)"
      assert_search_include "#{card.name}", card.name
      assert_search_include "#{card.name.downcase}", card.name
      assert_search_include "#{card.name.upcase}", card.name
    end
  end

  it "! //" do
    assert_search_results "!When / Where // What && Why", "Who", "What", "When", "Where", "Why"
    assert_search_results "!When // Where // Whatever"
  end

  it "//" do
    assert_search_results "//", "Who", "What", "When", "Where", "Why", "B.F.M. (Big Furry Monster)", "Naughty", "Nice"
    assert_search_results "When // Where // What", "Who", "What", "When", "Where", "Why"
    assert_search_results "When // Where // Whatever"
    assert_search_results "c:u // c:w // c:r", "Who", "What", "When", "Where", "Why"
    assert_search_results "c:u // c:u"

    # This is limitation of the syntax, I might change my mind about it,
    # but it only affects this one uncard
    assert_search_results "c:u // c:r // c:u", "Who", "What", "When", "Where", "Why"
  end

  it "deep other: nesting doesn't crash the engine" do
    assert_search_results("other:"*20 + "cmc=1", "Who", "What", "When", "Where", "Why")
    assert_search_results("other:"*20 + "cmc=6")
  end

  it "deep part: nesting doesn't crash the engine" do
    assert_search_results("part:"*20 + "cmc=1", "Who", "What", "When", "Where", "Why")
    assert_search_results("part:"*20 + "cmc=6")
  end
end

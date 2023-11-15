# This spec will get worse as they print black-bordered
# cards in HHO etc.

describe "Unsets" do
  include_context "db", "ugl", "unh", "pcel", "hho", "ust", "und", "unf"

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

  it "half mv" do
    "mv=1"  .should exclude_cards "Little Girl"
    "mv>0"  .should include_cards "Little Girl"
    "mv=0.5".should include_cards "Little Girl"
    "mv=½"  .should include_cards "Little Girl"
    "mv<1"  .should include_cards "Little Girl"
    "mv=1"  .should exclude_cards "Little Girl"
    "mv>1"  .should exclude_cards "Little Girl"
  end

  it "infinite power" do
    "pow>30".should return_cards "B.F.M. (Big Furry Monster)",
      "B.F.M. (Big Furry Monster, Right Side)",
      "Infinity Elemental"
    "pow=∞".should return_cards "Infinity Elemental"
    "pow>=∞".should return_cards "Infinity Elemental"
    assert_search_equal "pow<∞", "pow<10000"
    assert_search_equal "pow<=∞", "pow<=10000 or (Infinity Elemental)"
  end

  it "question mark power/toughness" do
    assert_search_results "pow=?", "Shellephant"
    assert_search_equal "pow=?", "pow>=?"
    assert_search_equal "pow=?", "pow<=?"
    assert_search_results "pow>?"
    assert_search_results "pow<?"

    assert_search_results "tou=?", "Shellephant"
    assert_search_equal "tou=?", "tou>=?"
    assert_search_equal "tou=?", "tou<=?"
    assert_search_results "tou>?"
    assert_search_results "tou<?"
  end

  it "border:none" do
    assert_search_equal "border:none -(e:unf t:land) -(e:unf Comet) -(e:unf Beleren)",
      "(e:ust (t:basic or t:contraption)) or
      (e:pcel Zur)"
    assert_search_equal "border:none", "is:borderless"
    assert_search_equal "not:borderless", "-is:borderless"
    # Can't have multiple borders
    assert_search_results "border:none border:black"
    assert_search_results "border:none border:white"
    assert_search_results "border:none border:silver"
  end

  it "is:funny" do
    "is:funny"          .should include_cards "Little Girl"
    "is:new"            .should include_cards "Little Girl"
    "is:silver-bordered".should include_cards "Little Girl"
    "not:black-bordered".should include_cards "Little Girl"
    "not:white-bordered".should include_cards "Little Girl"
    "not:funny -e:unf".should return_cards(
      "Forest",
      "Island",
      "Mountain",
      "Plains",
      "Swamp",
      "Steamflogger Boss",
      "Zur the Enchanter",
    )
    "not:new"           .should include_cards(
      "1996 World Champion",
      "Fraternal Exaltation",
      "Proposal",
      "Shichifukujin Dragon",
      "Splendid Genesis"
    )
    # (Old Fogey) is mtgjson bug
    "not:new -e:pcel -(Old Fogey)".should equal_search "(Blast from the Past) or e:ugl"
    "not:silver-bordered -t:contraption -e:unf".should return_cards(
      "1996 World Champion",
      "Chaos Wrap",
      "Forest",
      "Fraternal Exaltation",
      "Gifts Given",
      "Island",
      "Mountain",
      "Phoenix Heart",
      "Plains",
      "Proposal",
      "Robot Chicken",
      "Seasonal Sequels",
      "Shichifukujin Dragon",
      "Splendid Genesis",
      "Steamflogger Boss",
      "Stocking Tiger",
      "Swamp",
      "Zur the Enchanter",
    )
    "is:black-bordered -e:unf".should return_cards(
      "1996 World Champion",
      "Chaos Wrap",
      "Forest",
      "Fraternal Exaltation",
      "Gifts Given",
      "Island",
      "Mountain",
      "Phoenix Heart",
      "Plains",
      "Proposal",
      "Robot Chicken",
      "Seasonal Sequels",
      "Shichifukujin Dragon",
      "Splendid Genesis",
      "Steamflogger Boss",
      "Stocking Tiger",
      "Swamp",
    )
    "is:white-bordered".should return_no_cards
  end

  it "unf funny" do
    assert_search_equal "e:unf is:funny", "e:unf is:acorn"
  end

  it "unf funny" do
    assert_search_equal "e:unf f:vintage", "e:unf -is:acorn"
    assert_search_equal "e:unf f:legacy", "e:unf -is:acorn"
    assert_search_equal "e:unf f:commander", "e:unf -is:acorn"
    assert_search_equal "e:unf f:pauper", "e:unf -is:acorn (r:common or r:basic)"
  end

  it "edition shortcut syntax" do
    assert_search_equal "e:unh,ugl", "e:unh or e:ugl"
    assert_count_printings "e:unh,ugl", 261
  end

  it "other:" do
    assert_search_results "other:c:g", "What", "Who", "When", "Where"
    # Any other has cmc != 4
    assert_search_results "other:-cmc=4",
      "Who", "What", "When", "Where", "Why", "Naughty", "Nice",
      "B.F.M. (Big Furry Monster)", "B.F.M. (Big Furry Monster, Right Side)",
      "Curse of the Fire Penguin", "Curse of the Fire Penguin Creature",
      "Decorated Knight",
      "Omniclown Colossus", "Pie-roclasm"
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
    assert_search_results "//",
      "Who", "What", "When", "Where", "Why",
      "B.F.M. (Big Furry Monster)", "B.F.M. (Big Furry Monster, Right Side)",
      "Naughty", "Nice",
      "Curse of the Fire Penguin Creature", "Curse of the Fire Penguin",
      "Decorated Knight", "Present Arms",
      "Omniclown Colossus", "Pie-roclasm"
    assert_search_results "When // Where // What", "Who", "What", "When", "Where", "Why"
    assert_search_results "When // Where // Whatever"
    assert_search_results "c:u // c:w // c:r", "Who", "What", "When", "Where", "Why"
    assert_search_results "c:u // c:u", "Present Arms", "Decorated Knight"

    # This is limitation of the syntax, I might change my mind about it,
    # but it only affects this one uncard
    assert_search_results "c:u // c:r // c:u", "Who", "What", "When", "Where", "Why"
  end

  it "deep other: nesting doesn't crash the engine" do
    assert_search_results("other:"*20 + "cmc=1", "Who", "What", "When", "Where", "Why")
    assert_search_results("other:"*20 + "cmc=7")
  end

  it "deep part: nesting doesn't crash the engine" do
    assert_search_results("part:"*20 + "cmc=1", "Who", "What", "When", "Where", "Why")
    assert_search_results("part:"*20 + "cmc=7")
  end

  it "is:augment" do
    assert_search_equal "is:augment", 'o:"augment {"'
    assert_search_equal "-is:augment", "not:augment"
  end

  it "display_power / display_toughness" do
    validate = proc do |card, value, display_value|
      case value
      when nil
        display_value.should eq(nil)
      when Integer
        display_value.should eq(value)
      when 0.5
        display_value.should eq("½")
      when Float
        raise unless "#{value}" =~ /\A(\d+)\.5\z/
        display_value.should eq("#{$1}½")
      when String
        display_value.should eq(value)
      else
        raise "No idea what to do with #{value}"
      end
    end
    db.cards.values.each do |card|
      if card.augment
        card.display_power.should =~ /\A[+-]\d+\z/
        card.display_toughness.should =~ /\A[+-]\d+\z/
        card.display_power[0].should eq(card.display_toughness[0])
      else
        validate.(card, card.power, card.display_power)
        validate.(card, card.toughness, card.display_toughness)
      end
    end
  end

  it "is:acorn" do
    assert_search_equal "is:acorn", "is:acorn e:unf,hho"
  end

  it "light:" do
    assert_search_results "t:attraction r:r light:2 light:5",
      "Storybook Ride" # 2,5,6 and 3,4,6
    assert_search_equal "light:3", 'LIGHT:"3"'
    assert_search_equal "light:*", "t:attraction"
  end
end

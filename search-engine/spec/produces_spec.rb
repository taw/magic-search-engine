describe "produces queries" do
  include_context "db"

  it "parser" do
    assert_search_equal "produces:www", "PRODUCES:{W}"
    assert_search_equal "produces:{w/u}", "PRODUCES=WU"
    assert_search_equal "produces:{2/u}", "produces=u"
    assert_search_equal "produces:{pb}", "produces=b"

    assert_search_equal "produces>=wu", "produces=wu or produces>wu"
  end

  it "produces" do
    assert_search_include "produces=wub",
      "Raffine's Tower", # by land time
      "Dromar's Cavern", # by text
      "Ancient Spring" # by multiple texts

    assert_search_exclude "produces=wubrg",
      "Dromar's Cavern" # too few

    assert_search_include "produces>wub",
      "Birds of Paradise" # too many
  end

  # Tundra produces exactly WU, Plains only W, Bayou BG, and most cards
  # produce nothing at all, which the empty set makes a subset of everything
  it "subset comparisons" do
    assert_search_include "produces=wu", "Tundra"
    assert_search_exclude "produces=wu", "Plains", "Bayou", "Lightning Bolt"

    assert_search_include "produces<=wu", "Tundra", "Plains", "Lightning Bolt"
    assert_search_exclude "produces<=wu", "Bayou"

    assert_search_include "produces<wu", "Plains", "Lightning Bolt"
    assert_search_exclude "produces<wu", "Tundra", "Bayou"

    assert_search_include "produces!=wu", "Plains", "Bayou", "Lightning Bolt"
    assert_search_exclude "produces!=wu", "Tundra"
  end

  it "subset comparisons agree with each other" do
    assert_search_equal "produces!=wu", "-produces=wu"
    assert_search_equal "produces<wu", "produces<=wu -produces=wu"
    assert_search_equal "produces<=wu", "-produces>=b -produces>=r -produces>=g -produces>=c"
    # Nothing is a strict subset of the empty set
    assert_search_equal "produces<c", "produces="
  end

  it "to_s" do
    # Colors keep the order they were typed in, they're not normalized
    Query.new("produces>=gw").to_s.should eq("produces>=gw")
    Query.new("produces>gw").to_s.should eq("produces>gw")
    Query.new("produces<=gw").to_s.should eq("produces<=gw")
    Query.new("produces<gw").to_s.should eq("produces<gw")
    Query.new("produces!=gw").to_s.should eq("produces!=gw")
    Query.new("produces=").to_s.should eq("produces=")
    # Everything that isn't a color symbol is dropped, and `:` means `=`
    Query.new("produces:www").to_s.should eq("produces=w")
    Query.new("produces:{2/u}").to_s.should eq("produces=u")
  end

  it "produces from basic land types" do
    # Basic land types are subtypes, and mana from them must be counted even
    # when nothing in the text says "add"
    assert_search_include "produces=r",
      "Fabled Path of Searo Point" # Legendary Land - Mountain, text is only landwalk
    assert_search_include "produces=g",
      "Dryad Arbor" # Land Creature - Forest
    assert_search_include "produces=bg",
      "Bayou" # plain dual land

    # Mana in an activation cost is not mana produced
    assert_search_exclude "produces:w",
      "Fabled Path of Searo Point" # costs {W}{U}{B}{R}{G} to activate

    # Every card with a basic land type produces at least that color
    ["plains=w", "island=u", "swamp=b", "mountain=r", "forest=g"].each do |land|
      type, color = land.split("=")
      assert_search_equal "t:#{type}", "t:#{type} produces>=#{color}"
    end
  end
end

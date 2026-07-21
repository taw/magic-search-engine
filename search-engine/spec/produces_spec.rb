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

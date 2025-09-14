describe "devotion queries" do
  include_context "db"

  it "parser" do
    assert_search_equal "devotion:www", "DEVOTION={w}{w}{w}"
    assert_search_equal "devotion<bbb", "devotion<=bb"
    assert_search_equal "devotion:{ub}{ub}", "DEVOTION={B/U}{U/B}"
  end

  it "warnings" do
    # TODO
  end

  it "devotion to monocolored" do
    assert_search_include "devotion=bbb",
      "Ashenmoor Gouger", # all hybrid
      "Evelyn, the Covetous", # regular and hybrid
      "Debtors' Knell", # hybrid and colorless
      "K'rrik, Son of Yawgmoth" # phyrexian

    assert_search_exclude "devotion=bbb",
      "Black Knight", # 2 devotion
      "Phyrexian Obliterator", # 4 devotion
      "Archenemy's Charm", # instant
      "Cruel Bargain" # sorcery

    assert_search_include "devotion=b",
      "Reaper King" # 2-brid

    assert_search_include "devotion=gg",
      "Lukka, Bound to Ruin" # phyrexian hybrid

    assert_search_include "devotion={g}{g}{g}{g}",
      "Nissa, Ascended Animist" # regular and phyrexian
  end

  it "devotion to hybrid" do
    assert_search_include "devotion={g/r}{g/r}{g/r}",
      "Ayula's Influence", # regular green
      "Living Twister", # regular green and red
      "Ball Lightning", # regular red
      "Boartusk Liege", # hybrid r/g
      "Balefire Liege", # partly overlapping hybrid w/r
      "Lukka, Bound to Ruin" # phyrexian hybrid

    assert_search_include "devotion={rg}{rg}",
      "Reaper King" # twobrid and some others
  end
end

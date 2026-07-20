describe "devotion queries" do
  include_context "db"

  it "parser" do
    assert_search_equal "devotion:www", "DEVOTION={w}{w}{w}"
    assert_search_equal "devotion<bbb", "devotion<=bb"
    assert_search_equal "devotion:{ub}{ub}", "DEVOTION={B/U}{U/B}"

    # these are undocumented edge cases
    # they work but are not recommended
    assert_search_equal "devotion:{2/b}{2/b}", "DEVOTION={b}{b}"
    assert_search_equal "devotion:{pb}{pb}", "DEVOTION={b}{b}"
    assert_search_equal "devotion:{p/b}{2/b}{b}", "devotion:bbb"
    assert_search_equal "devotion:ub", "devotion=u and devotion=b"
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

  it "warns about generic mana, but otherwise ignores it" do
    generic_ignored = %[Generic mana in "devotion>=2ww" is ignored, devotion only counts colored mana symbols]
    db.search("devotion>=2ww").warnings.should include(generic_ignored)
    assert_search_equal "devotion>=2ww", "devotion>=ww"
    assert_search_equal "devotion>={2}{w}{w}", "devotion>=ww"

    # warning also has to reach queries where devotion is just one of the conditions
    db.search("devotion>=2ww t:creature").warnings.should include(generic_ignored)

    # {2/w} is a hybrid symbol, not generic mana, so no warning for it
    db.search("devotion>={2/w}").warnings.should be_empty
    db.search("devotion>=ww").warnings.should be_empty
  end
end

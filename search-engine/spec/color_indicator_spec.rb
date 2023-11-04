describe "Color Indicator Test" do
  include_context "db"

  it "indicator matches exactly" do
    # "Transguild Courier" used to be Oracled to color indicator WUBRG
    # but they reverted it when they printed "Sphinx of the Guildpact"
    # No card was actually printed like that
    assert_search_results "ind:wubrg"

    assert_search_results "ind:r t:creature cmc=0",
      "Crimson Kobolds",
      "Crookshank Kobolds",
      "Kobolds of Kher Keep",
      "Half-Orc, Half-",
      "Rograkh, Son of Rohgahh"
    assert_search_results "ind:r t:instant",
      "Pact of the Titan"
    assert_search_results "ind:w t:sorcery",
      "Restore Balance",
      "Resurgent Belief"
    assert_search_results "ind:rg",
      "Arlinn, Embraced by the Moon",
      "Arlinn, the Moon's Fury",
      "Blaster, Morale Booster",
      "Etali, Primal Sickness",
      "Lord of the Ulvenwald",
      "Plated Kilnbeast",
      "Ravager of the Fells",
      "Savage Packmate",
      "Tovolar, the Midnight Scourge",
      "Truga Cliffcharger",
      "Ulrich, Uncontested Alpha"
    assert_search_equal "ind:gr", "ind:rg"
    assert_search_equal "ind:grrgr", "ind:rg"
    assert_search_results "ind:ubr",
      "Nicol Bolas, the Arisen"
    assert_search_results "ind:wrg",
      "Grimlock, Ferocious King",
      "Roar of the Fifth People",
      "Ultra Magnus, Armored Carrier"
    assert_search_equal "ind:ubr", "ind:bur"
    assert_search_equal "ind:wrg", "ind:gwr"
  end

  it "ind:*" do
    assert_search_equal "ind:*", "ind>=c"
    assert_search_equal "ind:*", "has:indicator"
  end

  it "comparisons" do
    assert_search_equal "ind>=r", "ind=r OR ind>r"
    assert_search_equal "ind>r", "ind>=rg OR ind>=rw OR ind>=rb OR ind>=ru"
  end

  it "number" do
    assert_search_results "ind=5"
    assert_search_results "ind:wubrg"
    assert_search_equal "ind<3 -e:bot", "ind:* -t:bolas -grimlock -e:bot -(roar fifth people) -(The Golden-Gear Colossus)"
    assert_search_equal "ind<4", "ind:*"
    assert_search_results "ind<1"
  end

  it "c/l/m are ignored" do
    assert_search_equal "ind:rgm", "ind:rg"
    assert_search_equal "ind:rgl", "ind:rg"
    assert_search_equal "ind:rgc", "ind:rg"
  end

  it "bad indicators return no results silently" do
    "ind:l".should return_no_cards
    "ind:rug".should return_no_cards
    "ind:c".should return_no_cards
    "ind:rbgu".should return_no_cards
    "ind:rbgurgbu".should return_no_cards
  end
end

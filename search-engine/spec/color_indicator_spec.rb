describe "Color Indicator Test" do
  include_context "db"

  it "indicator matches exactly" do
    # "Transguild Courier" used to be Oracled to color indicator WUBRG
    # but they reverted it when they printed "Sphinx of the Guildpact"
    # No card was actually printed like that
    assert_search_results "in:wubrg"

    assert_search_results "in:r t:creature cmc=0",
      "Crimson Kobolds",
      "Crookshank Kobolds",
      "Kobolds of Kher Keep",
      "Half-Orc, Half-"
    assert_search_results "in:r t:instant",
      "Pact of the Titan"
    assert_search_results "in:w t:sorcery",
      "Restore Balance"
    assert_search_results "in:rg",
      "Arlinn, Embraced by the Moon",
      "Ravager of the Fells",
      "Ulrich, Uncontested Alpha"
    assert_search_equal "in:gr", "in:rg"
    assert_search_equal "in:grrgr", "in:rg"
  end

  it "in:*" do
    assert_search_equal "in:*", "in>=c"
  end

  it "comparisons" do
    assert_search_equal "in>=r", "in=r OR in>r"
    assert_search_equal "in>r", "in>=rg OR in>=rw OR in>=rb OR in>=ru"
  end

  it "number" do
    assert_search_results "in=5"
    assert_search_results "in:wubrg"
    assert_search_equal "in<3", "in:* -t:bolas -grimlock"
    assert_search_results "in<1"
  end

  it "c/l/m are ignored" do
    assert_search_equal "in:rgm", "in:rg"
    assert_search_equal "in:rgl", "in:rg"
    assert_search_equal "in:rgc", "in:rg"
  end

  it "bad indicators return no results silently" do
    "in:l".should return_no_cards
    "in:rug".should return_no_cards
    "in:c".should return_no_cards
    "in:rbgu".should return_no_cards
    "in:rbgurgbu".should return_no_cards
  end
end

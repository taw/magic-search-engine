describe "Color Indicator Test" do
  include_context "db"

  it "indicator matches exactly" do
    assert_search_results "in:wubrg",
      "Transguild Courier"
    assert_search_results "in:r t:creature cmc=0",
      "Crimson Kobolds",
      "Crookshank Kobolds",
      "Kobolds of Kher Keep"
    assert_search_results "in:r t:instant",
      "Pact of the Titan"
    assert_search_results "in:w t:sorcery",
      "Restore Balance"
    assert_search_results "in:rg",
      "Arlinn, Embraced by the Moon",
      "Ravager of the Fells"
    assert_search_equal "in:gr", "in:rg"
    assert_search_equal "in:grrgr", "in:rg"
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

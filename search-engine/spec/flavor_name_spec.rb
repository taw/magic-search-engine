describe "DissentionTest" do
  include_context "db", "iko", "plgs"

  it "fn:name" do
    assert_search_results "fn:corona",
      "Void Beckoner"
    assert_search_results "fn:godzilla",
      "Titanoth Rex",
      "Yidaro, Wandering Monster",
      "Zilortha, Strength Incarnate"
    assert_search_results "fn:mothra",
      "Luminous Broodmoth",
      "Mysterious Egg"
  end

  it "fn:*" do
    assert_count_cards "fn:* e:iko", 19
    assert_count_cards "fn:* e:plgs", 1
  end
end

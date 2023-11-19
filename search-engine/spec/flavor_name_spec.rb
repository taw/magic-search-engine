describe "DissentionTest" do
  include_context "db", "iko", "plg20"

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
    assert_count_cards "fn:* e:plg20", 1
  end

  it "normal name search matches fn" do
    assert_search_results "corona",
      "Void Beckoner"
      assert_search_results "godzilla",
      "Titanoth Rex",
      "Yidaro, Wandering Monster",
      "Zilortha, Strength Incarnate",
      # This search also matches substrings, so additional matches
      "Brokkos, Apex of Forever", # Spacegodzilla
      "Crystalline Giant", # Mechagodzilla
      "Hangarback Walker", # Mechagodzilla
      "Pollywog Symbiote", # Babygodzilla
      "Void Beckoner" # Spacegodzilla

    assert_search_results "mothra",
      "Luminous Broodmoth",
      "Mysterious Egg"
  end

  it "regexp name search does not match fn" do
    assert_search_results "n:/corona/"
    assert_search_results "n:/godzilla/"
    assert_search_results "n:/mothra/"
  end
end

describe "Card nicknames" do
  include_context "db"

  it "is:shockland" do
    assert_search_results "is:shockland",
      "Blood Crypt",
      "Breeding Pool",
      "Godless Shrine",
      "Hallowed Fountain",
      "Overgrown Tomb",
      "Sacred Foundry",
      "Steam Vents",
      "Stomping Ground",
      "Temple Garden",
      "Watery Grave"
  end

  it "is:fetchland" do
    assert_search_results "is:fetchland",
      "Arid Mesa",
      "Marsh Flats",
      "Misty Rainforest",
      "Scalding Tarn",
      "Verdant Catacombs",
      "Bloodstained Mire",
      "Flooded Strand",
      "Polluted Delta",
      "Windswept Heath",
      "Wooded Foothills"
  end
end

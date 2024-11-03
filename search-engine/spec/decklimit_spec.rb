describe "DissentionTest" do
  include_context "db"

  it "decklimit:" do
    assert_search_results "decklimit=1", "Once More with Feeling"
    assert_search_results "decklimit=7", "Seven Dwarves"
    assert_search_results "decklimit=9", "Nazgûl"
    assert_search_results "decklimit=any",
      # normal basics
      "Forest",
      "Island",
      "Mountain",
      "Plains",
      "Swamp",
      # snow covered basics
      "Snow-Covered Forest",
      "Snow-Covered Island",
      "Snow-Covered Mountain",
      "Snow-Covered Plains",
      "Snow-Covered Swamp",
      "Snow-Covered Wastes",
      # fancy basics
      "Barry's Land",
      "Omnipresent Impostor",
      "Wastes",
      # by card text
      "Dragon's Approach",
      "Hare Apparent",
      "Persistent Petitioners",
      "Rat Colony",
      "Relentless Rats",
      "Shadowborn Apostle",
      "Slime Against Humanity",
      "Templar Knight"
  end
end

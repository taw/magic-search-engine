describe "Deck legality" do
  include_context "db"

  it "allowed_in_any_number?" do
    db.printings.select(&:allowed_in_any_number?).map(&:name).uniq.should match_array([
      "Forest",
      "Island",
      "Mountain",
      "Persistent Petitioners",
      "Plains",
      "Rat Colony",
      "Relentless Rats",
      "Shadowborn Apostle",
      "Snow-Covered Forest",
      "Snow-Covered Island",
      "Snow-Covered Mountain",
      "Snow-Covered Plains",
      "Snow-Covered Swamp",
      "Swamp",
      "Wastes",
    ])
  end
end

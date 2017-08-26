describe "Name Comparison" do
  include_context "db"

  it do
    assert_search_results(
      %Q[
        f:Modern
        print<=M14
        t:land
        name>"Selesnya Guildgate"
        name<"Simic Guildgate"
      ],
      "Selesnya Sanctuary",
      "Seraph Sanctuary",
      "Shelldock Isle",
      "Shimmering Grotto",
      "Shinka, the Bloodsoaked Keep",
      "Shivan Oasis",
      "Shivan Reef",
      "Shizo, Death's Storehouse",
      "Simic Growth Chamber"
    )
  end
end

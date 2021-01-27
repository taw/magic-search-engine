describe "Name Comparison" do
  include_context "db"

  it do
    assert_search_results(
      %[
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

  it "punctuation" do
    assert_search_include %[e:aer name>"Sram, Senior Edificer"],
      "Sram's Expertise"
    assert_search_include %[e:akh name>"Liliana, Death's Majesty"],
      "Liliana's Mastery"
    assert_search_include %[e:kld name<"Consul's Shieldguard"],
      "Consulate Surveillance"
  end

  it "=" do
    assert_search_results %[name="Painter's Servant" or name=Grindstone],
      "Painter's Servant",
      "Grindstone"
  end

  it "aliases" do
    assert_search_equal "name=bitterblossom", "n=bitterblossom"
    assert_search_equal "name=bitterblossom", "n:bitterblossom"
    assert_search_equal "name=bitterblossom", "name:bitterblossom"
    assert_search_equal "name=/goblin/", "n=/goblin/"
    assert_search_equal "name=/goblin/", "n:/goblin/"
    assert_search_equal "name=/goblin/", "name:/goblin/"
  end
end

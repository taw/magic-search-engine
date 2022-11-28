describe "Type expr" do
  include_context "db"

  it "=" do
    assert_search_results "t=creature",
      "Nameless Race"
    assert_search_results 't="basic land"',
      "Wastes"
    assert_search_results 't="land forest"',
      "Gingerbread Cabin",
      "Murmuring Bosk",
      "Sapseep Forest"
    assert_search_results 't="creature elf" e:8ed',
      "Elvish Champion",
      "Elvish Lyrist",
      "Elvish Scrapper",
      "Gaea's Herald"
  end

  it ">= is :" do
    assert_search_equal "t:elf", 't>=elf'
  end

  it ">= is > or =" do
    assert_search_equal 't>"creature elf"', 't>="creature elf" -t="creature elf"'
  end

  # I don't really need many uses for <= and <
  # These are mostly for completeness
  # You can maybe do some weird OR with it

  it "<" do
    assert_search_results 't<="basic land forest mountain" t:basic',
      "Forest",
      "Mountain",
      "Wastes"
    assert_search_results 't<"basic land forest mountain" t>land',
      "Cinder Glade",
      "Dwarven Mine",
      "Forest",
      "Gingerbread Cabin",
      "Madblind Mountain",
      "Mountain",
      "Murmuring Bosk",
      "Sapseep Forest",
      "Sheltered Thicket",
      "Stomping Ground",
      "Taiga",
      "Wastes",
      "Wooded Ridgeline"
  end
end

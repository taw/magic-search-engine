describe "Conspiracy" do
  include_context "db", "cns", "cn2"

  it "conspiracy" do
    assert_search_results 't:conspiracy o:"one mana of any color"',
      "Secrets of Paradise",
      "Sovereign's Realm",
      "Worldknit"
  end

  it "conspiracy cards included by default" do
    assert_search_results 'o:"one mana of any color"',
      "Birds of Paradise",
      "Exotic Orchard",
      "Mirrodin's Core",
      "Opaline Unicorn",
      "Paliano, the High City",
      "Regal Behemoth",
      "Secrets of Paradise",
      "Shimmering Grotto",
      "Sovereign's Realm",
      "Spectral Searchlight",
      "Worldknit"
    end

  it "! search doesnt require explicit flags" do
    assert_search_results "!Secrets of Paradise", "Secrets of Paradise"
  end

  it "t:* does nothing" do
    assert_search_equal "t:* t:creature", "t:creature"
    assert_search_equal "t:* t:conspiracy", "t:conspiracy"
    assert_count_printings "e:cns", 210
    assert_count_printings "t:* e:cns", 210
  end

  it "is:draft" do
    assert_search_equal "is:draft", "t:conspiracy or o:draft"
    assert_count_printings "e:cns not:draft", 80 + 60 + 35 + 10
    # Including foil Kaya
    assert_count_printings "e:cn2 not:draft", 80 + 60 + 42 + 12 + 1
  end
end

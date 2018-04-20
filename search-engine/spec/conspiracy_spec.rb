describe "Conspiracy" do
  include_context "db", "cns"

  it "conspiracy" do
    assert_search_results 't:conspiracy o:"one mana of any color"',
      "Secrets of Paradise",
      "Worldknit"
  end

  it "conspiracy cards included by default" do
    assert_search_results 'o:"one mana of any color"',
      "Mirrodin's Core",
      "Paliano, the High City",
      "Secrets of Paradise",
      "Spectral Searchlight",
      "Worldknit"
  end

  it "! search doesnt require explicit flags" do
    assert_search_results "!Secrets of Paradise", "Secrets of Paradise"
  end

  it "t:* does nothing" do
    assert_search_equal "t:* t:creature", "t:creature"
    assert_search_equal "t:* t:conspiracy", "t:conspiracy"
    assert_count_results "e:cns", 210
    assert_count_results "t:* e:cns", 210
  end
end

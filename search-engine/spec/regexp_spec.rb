describe "Regexp" do
  include_context "db"

  it "handles parse errors" do
    Query.new('o:/\d+/').warnings.should eq([])
    Query.new('o:/[a-z/').warnings.should eq(["bad regular expression in o:/[a-z/ - premature end of char-class: /[a-z/i"])
    Query.new('o:/[a-z]/').warnings.should eq([])
    Query.new('FT:/[a-z/').warnings.should eq(["bad regular expression in FT:/[a-z/ - premature end of char-class: /[a-z/i"])
    Query.new('FT:/[a-z]/').warnings.should eq([])
  end

  it "handles timeouts" do
    # It's quite hard to construct pathological regexp by accident
    proc{ search('o:/([^e]?){50}[^e]{50}/') }.should raise_error(Timeout::Error)
  end

  it "regexp oracle text" do
    assert_search_results 'o:/\d{3,}/',
      "1996 World Champion",
      "Ajani, Mentor of Heroes",
      "Battle of Wits",
      "Helix Pinnacle",
      "Knight of the Hokey Pokey",
      "Mox Lotus"
  end

  it "regexp flavor text" do
    assert_search_results 'ft:/\d{4,}/',
      "Akroma, Angel of Wrath Avatar",
      "Fallen Angel Avatar",
      "Goblin Secret Agent",
      "Gore Vassal",
      "Mise",
      "Nalathni Dragon",
      "Remodel",
      "The Ultimate Nightmare of Wizards of the Coast® Customer Service"

    assert_search_equal 'ft:/ajani/', 'FT:/ajani/'
    assert_search_equal 'ft:/ajani/', 'FT:/AJANI/'
    assert_search_equal 'ft:/land/', 'FT:/(?i)land/'
    assert_search_differ 'ft:/land/', 'FT:/(?-i)land/'
    assert_search_differ 'ft:/land/', 'FT:/\bland\b/'
  end
end

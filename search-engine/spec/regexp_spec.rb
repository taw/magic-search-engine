describe "Regexp" do
  include_context "db"

  context "handles parse errors" do
    it "o:" do
      Query.new('o:/\d+/').warnings.should eq([])
      Query.new('o:/[a-z/').warnings.should eq(["bad regular expression in o:/[a-z/ - premature end of char-class: /[a-z/mi"])
      Query.new('o:/[a-z]/').warnings.should eq([])
    end

    it "ft:" do
      Query.new('FT:/[a-z/').warnings.should eq(["bad regular expression in FT:/[a-z/ - premature end of char-class: /[a-z/mi"])
      Query.new('FT:/[a-z]/').warnings.should eq([])
    end

    it "a:" do
      Query.new('a:/[a-z/').warnings.should eq(["bad regular expression in a:/[a-z/ - premature end of char-class: /[a-z/mi"])
      Query.new('a:/[a-z]/').warnings.should eq([])
    end

    it "n:" do
      Query.new('n:/[a-z/').warnings.should eq(["bad regular expression in n:/[a-z/ - premature end of char-class: /[a-z/mi"])
      Query.new('n:/[a-z]/').warnings.should eq([])
    end

    it "rulings:" do
      Query.new('rulings:/[a-z/').warnings.should eq(["bad regular expression in rulings:/[a-z/ - premature end of char-class: /[a-z/mi"])
      Query.new('rulings:/[a-z]/').warnings.should eq([])
    end
  end

  # This is handled by the frontend now
  # it "handles timeouts" do
  #   # It's quite hard to construct pathological regexp by accident
  #   proc{ search('o:/([^e]?){50}[^e]{50}/') }.should raise_error(Timeout::Error)
  # end

  it "regexp oracle text" do
    # This gets updated too much from SLD etc. so promos excluded
    assert_search_results 'o:/\d{3,}/ -is:promo -e:unk',
      "A Good Thing",
      "Ajani, Mentor of Heroes",
      "As Luck Would Have It",
      "Battle of Wits",
      "Bilbo, Birthday Celebrant",
      "Dawnsire, Sunstar Dreadnought",
      "Helix Pinnacle",
      "Jumbo Cactuar",
      "Mox Lotus",
      "Overkill",
      "Pyromancy 101",
      "Rules Lawyer",
      "The Millennium Calendar",
      "TL;DR",
      "Urza, Academy Headmaster",
      "Vexing Puzzlebox"
  end

  it "regexp flavor text" do
    assert_search_results 'ft:/\d{4,}/ -e:olgc,ovnt,pewk,sld,unk',
      "Aardwolf's Advantage",
      "Atomize",
      "Automatic Librarian",
      "Bastion of Remembrance",
      "Fervent Champion",
      "Frostboil Snarl",
      "Gilded Lotus",
      "Goblin Secret Agent",
      "Gore Vassal",
      "Invoke the Divine",
      "Mise",
      "Nalathni Dragon",
      "Remodel",
      "Salvation Engine",
      "Spinnerette, Arachnobat",
      "Suppressor Skyguard",
      "Voyager Glidecar"

    assert_search_equal 'ft:/ajani/', 'FT:/ajani/'
    assert_search_equal 'ft:/ajani/', 'FT:/AJANI/'
    assert_search_equal 'ft:/land/', 'FT:/(?i)land/'
    assert_search_differ 'ft:/land/', 'FT:/(?-i)land/'
    assert_search_differ 'ft:/land/', 'FT:/\bland\b/'
  end

  it "regexp artist text" do
    db.search("a:/.{40}/").printings.map(&:artist_name).should match_array([
      "Jim \"Stop the Da Vinci Beatdown\" Pavelec",
      "Pete \"Yes the Urza's Legacy One\" Venters",
      "Alan \"Don't Feel Like You Have to Pick Me\" Pollack",
      "Poison Project (USE ANDITYA DITA INSTEAD)",
    ])
  end

  it "regexp name text" do
    assert_search_results "f:modern n:/.{32}/",
      "Aetherwing, Golden-Scale Flagship",
      "Okina, Temple to the Grandfathers",
      "World Champion, Celestial Weapon"
  end

  it "regexp rulings text" do
    assert_search_results "rulings:fly",
      "Devil K. Nevil",
      "Druid of Purification",
      "Wings of Hubris",
      "Sarah's Wings"
    assert_search_equal "rulings:flying", 'rulings:/\bflying\b/'
    assert_search_include 'rulings:/\d{5,}/', "Bloodletter"
  end
end

describe "Color Expr Test" do
  include_context "db"

  it "one color" do
    assert_search_equal "c=r", "c!r"
    assert_search_equal "c>=r", "c:r"
  end

  it "multiple colors" do
    assert_search_equal "c>=g c>=r", "c>=rg"
    assert_search_equal "c>g", "c>=g (c>=w or c>=u or c>=b or c>=r)"
  end

  it "other operators" do
    assert_search_equal "c>=gr", "c>r c>g"
    assert_search_equal "c<=gr", "c<=r or c<=g or c=gr"
  end

  it "colorless" do
    assert_search_equal "c=c", "c<w"
  end

  it "ci - one color" do
    assert_search_equal "ci<=uw", "ci:uw"
  end

  it "ci multiple colors" do
    assert_search_equal "ci>=g ci>=r", "ci>=rg"
    assert_search_equal "ci>g", "ci>=g (ci>=w or ci>=u or ci>=b or ci>=r)"
  end

  it "ci other operators" do
    assert_search_equal "ci>=gr", "ci>r ci>g"
    assert_search_equal "ci<=gr", "ci<=r or ci<=g or ci=gr"
  end

  it "colorless" do
    assert_search_equal "ci=c", "ci<w"
  end

  it "is case insensitive" do
    assert_search_equal "ci=wur", "ci=WUR"
    assert_search_equal "c=wur", "c=WUR"
    assert_search_equal "CI=wur", "ci=WUR"
    assert_search_equal "C=wur", "c=WUR"
  end

  it "number of colors" do
    assert_search_equal "c=0", "c=c"
    assert_search_equal "c=1", "c=w or c=u or c=b or c=r or c=g"
    assert_search_equal "c>=3", "c=3 or c=4 or c=5"
    assert_search_equal "c>3", "c=4 or c=5"
    assert_search_equal "c<=3", "c=3 or c=2 or c=1 or c=0"
    assert_search_equal "c<3", "c=2 or c=1 or c=0"
    assert_search_results "c=w ci=5",
      "Bringer of the White Dawn",
      "General Tazri",
      "Kenrith, the Returned King",
      "Kyodai, Soul of Kamigawa",
      "Leonardo, the Balance",
      "Nick Fury, Agent of S.H.I.E.L.D.",
      "Paragon of the Amesha",
      "Sisay, Weatherlight Captain",
      "Tazri, Beacon of Unity",
      "Tazri, Stalwart Survivor",
      "Who",
      "You, Iterative Playtester",
      "You, Magic Playtester"
  end

  it "number of color identity" do
    assert_search_equal "ci=0", "ci=c"
    assert_search_equal "ci=1", "ci=w or ci=u or ci=b or ci=r or ci=g"
    assert_search_equal "ci>=3", "ci=3 or ci=4 or ci=5"
    assert_search_equal "ci>3", "ci=4 or ci=5"
    assert_search_equal "ci<=3", "ci=3 or ci=2 or ci=1 or ci=0"
    assert_search_equal "ci<3", "ci=2 or ci=1 or ci=0"
  end

  # there' been a few changes in the new color engine
  it "MCI style queries" do
    assert_search_equal "c!boros", "c!wr"
    assert_search_equal "c:boros", "c=wr"
    assert_search_equal "c>=boros", "c:wr"
    assert_search_equal "c!abzan", "c!bwg"
    assert_search_equal "c>=abzan", "c:bwg"
    assert_search_equal "c:abzan", "c=bwg"
    assert_search_equal "c!green", "c!g"
    assert_search_equal "c:green", "c=g" # changed
    assert_search_equal "c>=green", "c:g" # changed

    assert_search_equal "c!w", "c=w"
    assert_search_equal "c:w", "c>=w"
    assert_search_equal "c!c", "c=0"
    assert_search_equal "c:c", "c=0"
    assert_search_equal "c:m", "c>1"
    assert_search_equal "c:mr", "c>r"
    # These used to do silly things, no more:
    assert_search_equal "c:mur", "c>=ur"
    assert_search_equal "c!mur", "c=ur"
    # No longer supported, and in fact changed a few times
    assert_search_results "c!m" # can't be both multicolored and colorless
    assert_search_results "c!mr" # can't be both multicolored and exactly-red
  end

  it "Fallaji" do
    assert_search_equal "ci=1 c=5", "Fallaji Wayfarer"
  end

  # A color query which isn't a color name keeps only the letters which happen to be color letters.
  # That's nonsense, but there's nothing better to do with such queries, so at least warn about it.
  it "unrecognized color queries warn" do
    Query.new("c:goblin").warnings.should == [%[Unrecognized color query: "goblin", correcting to "gb"]]
    Query.new("ci:zombie").warnings.should == [%[Unrecognized color query: "zombie", correcting to "mb"]]
    Query.new("ind:goblin").warnings.should == [%[Unrecognized color query: "goblin", correcting to "gb"]]
    # Nothing color-like left at all, so it ends up asking for colorless
    Query.new("c:elf").warnings.should == [%[Unrecognized color query: "elf", correcting to ""]]
    assert_search_equal "c:goblin", "c=gb"
    assert_search_equal "c:elf", "c=c"

    # Color names, guild/shard/wedge names, letters, counts, and the special values are all fine
    ["c:red", "c:boros", "c:abzan", "c:wu", "c:c", "c:m", "c:3", "c:ally", "c:allied", "c:enemy",
     "c:shard", "c:wedge", "c:*", "c:colorless", "c:multicolor", "c:multicolored"].each do |query|
      Query.new(query).warnings.should eq([]), "#{query} should not warn"
    end
  end
end

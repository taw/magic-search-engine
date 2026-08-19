describe "is:specialformat" do
  include_context "db"

  # Phenome-nom is Unstable's joke spelling of Phenomenon, and the only card
  # where the type doesn't name one of the categories below. The Theros challenge
  # decks and ppc1 have no card type of their own, so they come from the set instead.
  it "is card types no format can play, plus the challenge deck products" do
    assert_search_equal "is:specialformat",
      "t:vanguard or t:plane or t:phenomenon or t:phenome-nom or t:scheme or t:conspiracy or is:hero or e:tbth,tfth,tdag,ppc1"
  end

  it "is legal in no format at any date" do
    assert_search_results "is:specialformat format:*"
    assert_search_results "is:specialformat format:* time=2010-01-01"
  end

  # Alchemy cards used to share this flag. They're ordinary cards with an unusual
  # card pool, and they are legal on Arena.
  it "does not include Alchemy" do
    assert_search_results "is:specialformat is:alchemy"
    assert_search_equal "is:alchemy legal:historic", "is:alchemy -banned:historic"
  end

  # Formats never ask about special format cards on Arena, and nothing enforces that,
  # so pin it - Historic, Alchemy and Timeless skip the check entirely.
  it "never appears on Arena" do
    assert_search_results "is:specialformat game:arena"
  end

  # These were only ever funny because there was nowhere else to put them.
  # ppc1 is Garruk the Slayer, the M15 prerelease challenge boss.
  it "covers Hero's Path, the challenge decks and ppc1, which are not funny" do
    assert_search_equal "e:thp1,thp2,thp3", "e:thp1,thp2,thp3 is:specialformat"
    assert_search_equal "e:tbth,tfth,tdag", "e:tbth,tfth,tdag is:specialformat"
    assert_search_equal "e:ppc1", "e:ppc1 is:specialformat"
    assert_search_results "e:thp1,thp2,thp3,tbth,tfth,tdag,ppc1 is:funny"
  end

  # Astral cards are ordinary cards for the Shandalar computer game, not jokes.
  # Call from the Grave is the one with a paper printing, an mb2 playtest card,
  # which is not a real card either - so it stays legal in nothing.
  it "leaves Astral cards out of is:funny without making them legal" do
    assert_search_results "e:past is:funny"
    assert_search_results "e:past format:*"
  end

  # Reminder text on these cards states the variant's own rules and appears nowhere else,
  # so it survives the reminder text stripping that ordinary cards get
  it "keeps parenthetical rules text" do
    assert_search_equal %[o:"an ongoing scheme remains face up"], "t:scheme t:ongoing"
    assert_search_equal %[o:"start the game with this conspiracy"], "t:conspiracy"
  end
end

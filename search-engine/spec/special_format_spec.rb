describe "is:specialformat" do
  include_context "db"

  # Phenome-nom is Unstable's joke spelling of Phenomenon, and the only card
  # where the type doesn't name one of the categories below. The Theros challenge
  # decks have no card type of their own, so they come from the set instead.
  it "is card types no format can play, plus the Theros challenge decks" do
    assert_search_equal "is:specialformat",
      "t:vanguard or t:plane or t:phenomenon or t:phenome-nom or t:scheme or t:conspiracy or is:hero or e:tbth,tfth,tdag"
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
  it "covers Hero's Path and the Theros challenge decks, which are not funny" do
    assert_search_equal "e:thp1,thp2,thp3", "e:thp1,thp2,thp3 is:specialformat"
    assert_search_equal "e:tbth,tfth,tdag", "e:tbth,tfth,tdag is:specialformat"
    assert_search_results "e:thp1,thp2,thp3,tbth,tfth,tdag is:funny"
  end

  # Reminder text on these cards states the variant's own rules and appears nowhere else,
  # so it survives the reminder text stripping that ordinary cards get
  it "keeps parenthetical rules text" do
    assert_search_equal %[o:"an ongoing scheme remains face up"], "t:scheme t:ongoing"
    assert_search_equal %[o:"start the game with this conspiracy"], "t:conspiracy"
  end
end

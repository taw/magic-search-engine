 describe "Game queries" do
  include_context "db"

  it "is_digital" do
    # Not very reliable spec
    # not sure what to believe about (e:fca number:/†/)
    # spg has really dumb mix of Arena and paper cards with no good regexp
    assert_search_equal "is:digital -e:spg", "e:me1,me2,me3,me4,vma,tpr,pana,pmoa,td0,td2,ana,pz1,pz2,prm,ha1,ha2,ha3,ha4,ha5,ha6,ha7,ea1,ea2,ea3,xana,past,psdg,ajmp,akr,anb,oana,klr,j21,yneo,ymid,ysnc,hbg,ydmu,ybro,yone,ywoe,ylci,sir,sis,ymkm,yotj,yblb,ydsk,ydft,ytdm,pio,pa1,yeoe,aa1,aa2,aa3,aa4,omb,om1,yecl,ysos or
    (e:iko number=275a,373a) or (e:znr,mid number:/†/) or is:alchemy or (Name Sticker Goblin) or (e:dom,iko,ktk number:/y/) or (Vizzerdrix number:/a/) -e:spg"
  end

  it "is:paper" do
    assert_search_equal "is:paper", "game:paper"
    # This should work once everything is migrated and all issues fixed:
    # (or something like that without gold bordered / oversized / etc.)
    assert_search_results "is:paper is:digital"
    assert_search_results "is:paper border:gold"
    assert_search_results "is:paper is:oversized"
  end

  it "is:mtgo" do
    assert_search_equal "is:mtgo", "game:mtgo"
  end

  # We could have a better spec here
  it "is:arena" do
    assert_search_equal "is:arena", "game:arena"
    assert_search_equal "e:m19 is:arena", "e:m19"
    assert_search_results "e:isd is:arena", "Gnaw to the Bone" # MKM_ARENA_CU on Arena List
  end

  it "is:shandalar" do
    assert_search_equal "is:shandalar", "game:shandalar"
  end

  # The Dreamcast game's pool was all 335 cards of 6th Edition,
  # 9 cards reprinted from older sets, and 10 cards exclusive to the game
  it "is:dreamcast" do
    assert_search_equal "is:dreamcast", "game:dreamcast"
    assert_search_equal "is:dreamcast", "is:sega"
    assert_search_equal "in:dreamcast", "in:sega"
    assert_count_cards "is:dreamcast", 354
    assert_count_cards "e:6ed", 335
    assert_count_cards "e:psdg is:dreamcast", 10
    assert_search_results "is:dreamcast -e:6ed,psdg",
      "Bad Moon",
      "Death Pits of Rath",
      "Icy Manipulator",
      "Mox Diamond",
      "Nevinyrral's Disk",
      "Swords to Plowshares",
      "Thawing Glaciers",
      "Tradewind Rider",
      "Winter Orb"
    # Cards exclusive to the game got reprinted eventually, only the original is in the pool
    assert_search_equal "Arden Angel is:dreamcast", "Arden Angel e:psdg"
    assert_count_printings "Arden Angel", 2
  end
end

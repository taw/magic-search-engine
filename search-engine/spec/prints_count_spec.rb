describe "prints=N: queries" do
  include_context "db"

  it "generalizes alt:" do
    assert_search_equal "prints>=1:e:m10", "alt:e:m10"
    assert_search_equal "prints=0:e:m10", "-alt:e:m10"
    assert_search_equal "prints>=1:(a:\"Rebecca Guay\")", "alt:(a:\"Rebecca Guay\")"
  end

  it "counts every printing when the subquery matches everything" do
    assert_search_equal "prints>=2:*", "prints>=2"
    assert_search_equal "prints=1:*", "prints=1"
    assert_search_equal "prints<4:*", "prints<4"
  end

  it "counts printings of the card, not of the candidates" do
    # Basics are the only M10 cards with more than one printing in M10 itself
    assert_search_results "e:m10 prints>=2:e:m10",
      "Forest", "Island", "Mountain", "Plains", "Swamp"
    assert_search_equal_cards "e:m10 prints>=2:e:m10", "e:m10 t:basic"
  end

  it "matches cards with no matching printing at all" do
    "prints=0:e:lea".should include_cards("Squire")
    "prints<1:e:lea".should include_cards("Squire")
    "prints=0:e:lea".should exclude_cards("Black Lotus")
  end

  # The reason this exists - booster sheets need "cards which got N Booster Fun
  # treatments", which otherwise has to be written out as a disjunction over every
  # combination of treatments
  context "Booster Fun treatment counting" do
    let(:versions) { "e:mh3 number:320-467 -is:foilonly" }

    it "splits mh3 rares by number of treatments" do
      assert_count_printings "e:mh3 r:r prints=1:(#{versions}) (#{versions}) is:mainfront is:nonfoil", 43
      assert_count_printings "e:mh3 r:r prints=2:(#{versions}) (#{versions}) is:mainfront is:nonfoil", 36
      assert_count_printings "e:mh3 r:r prints>=3:(#{versions}) (#{versions}) is:mainfront is:nonfoil", 15
    end

    it "splits mh3 mythics by number of treatments" do
      assert_count_printings "e:mh3 r:m prints=1:(#{versions}) (#{versions}) is:mainfront is:nonfoil", 17
      assert_count_printings "e:mh3 r:m prints>=2:(#{versions}) (#{versions}) is:mainfront is:nonfoil", 14
    end

    it "finds the msh cards with two Booster Fun versions" do
      # msh-play.yaml has these two lists pasted in as collector numbers
      assert_count_printings "e:msh is:baseset r:r prints=2:(e:msh number:297-379) is:mainfront is:nonfoil", 5
      assert_count_printings "e:msh is:baseset r:m prints=2:(e:msh number:297-379) is:mainfront is:nonfoil", 13
      assert_search_equal \
        "e:msh is:baseset r:r prints=2:(e:msh number:297-379)",
        "e:msh is:baseset r:r number:25,97,213,220,244"
    end
  end
end

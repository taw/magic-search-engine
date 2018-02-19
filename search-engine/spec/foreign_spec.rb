describe "Any queries" do
  include_context "db"

  it "includes German name" do
    assert_search_equal %Q[foreign:"Abrupter Verfall"], %Q[de:"Abrupter Verfall"]
    assert_search_equal %q[foreign:/\bvon der\b/], %q[de:/\bvon der\b/]
  end

  context "French name" do
    it do
      assert_search_equal %Q[foreign:"Décomposition abrupte"], %Q[fr:"Décomposition abrupte"]
    end
    it "is case insensitive" do
      assert_search_equal %Q[foreign:"Décomposition abrupte"], %Q[foreign:"décomposition ABRUPTE"]
    end
    it "ignores diacritics" do
      assert_search_equal %Q[foreign:"Décomposition abrupte"], %Q[foreign:"Decomposition abrupte"]
    end
  end

  it "includes Italian name" do
    assert_search_equal %Q[foreign:"Deterioramento Improvviso"], %Q[it:"Deterioramento Improvviso"]
  end

  it "includes Japanese name" do
    assert_search_equal %Q[foreign:"血染めの月"], %Q[jp:"血染めの月"]
  end

  it "includes Russian name" do
    assert_search_equal %Q[foreign:"Кровавая луна"], %Q[ru:"Кровавая луна"]
  end

  it "includes Spanish name" do
    assert_search_equal %Q[foreign:"Puente engañoso"], %Q[sp:"Puente engañoso"]
  end

  it "includes Portuguese name" do
    assert_search_equal %Q[foreign:"Ponte Traiçoeira"], %Q[pt:"Ponte Traiçoeira"]
  end

  it "includes Korean name" do
    assert_search_equal %Q[foreign:"축복받은 신령들"], %Q[kr:"축복받은 신령들"]
    assert_search_equal %q[foreign:/축복받은/], %q[kr:/축복받은/]
  end

  it "includes Chinese Traditional name" do
    assert_search_equal %Q[foreign:"刻拉諾斯的電擊"], %Q[ct:"刻拉諾斯的電擊"]
  end

  it "includes Chinese Simplified name" do
    assert_search_equal %Q[foreign:"刻拉诺斯的电击"], %Q[cs:"刻拉诺斯的电击"]
  end

  it "wildcard" do
    assert_search_equal "t:planeswalker -ru:* de:*", "t:planeswalker e:c14"
  end
end

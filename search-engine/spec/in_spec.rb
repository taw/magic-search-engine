describe "in queries" do
  include_context "db"

  it "in:paper" do
    assert_search_equal "in:paper", "alt:game:paper"
  end

  it "in:mtgo" do
    assert_search_equal "in:mtgo", "alt:game:mtgo"
  end

  it "in:arena" do
    assert_search_equal "in:arena", "alt:game:arena"
  end

  it "in:booster" do
    assert_search_equal "in:booster", "alt:is:booster"
  end

  it "in:foil" do
    assert_search_equal "in:foil", "alt:in:foil"
  end

  it "in:nonfoil" do
    assert_search_equal "in:nonfoil", "alt:in:nonfoil"
  end
end

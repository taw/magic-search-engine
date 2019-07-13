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
end

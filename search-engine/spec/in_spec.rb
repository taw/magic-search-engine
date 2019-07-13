describe "in queries" do
  include_context "db"

  it "it:paper" do
    assert_search_equal "in:paper", "alt:game:paper"
  end

  it "it:mtgo" do
    assert_search_equal "in:mtgo", "alt:game:mtgo"
  end

  it "it:arena" do
    assert_search_equal "in:arena", "alt:game:arena"
  end
end

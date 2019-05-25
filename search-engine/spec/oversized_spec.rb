describe "Oversized cards" do
  include_context "db"

  it "is:oversized" do
    assert_search_equal "is:oversized", "t:plane or t:phenomenon or t:scheme"
    assert_search_equal "not:oversized", "-(is:oversized)"
  end
end

describe "Ixalan" do
  include_context "db", "xln"

  it "DFC cmc" do
    assert_search_equal "t:land cmc>0", "is:dfc t:land"
  end
end

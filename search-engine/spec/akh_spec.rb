describe "Amonkhet block" do
  include_context "db", "akh", "hou"

  it "is:front" do
    assert_search_equal "is:front", "*"
  end

  it "is:primary" do
    assert_search_equal "is:primary", "-is:secondary"
    assert_search_equal "is:primary", "-number:/b/"
    assert_search_equal "is:secondary", "o:aftermath"
  end
end

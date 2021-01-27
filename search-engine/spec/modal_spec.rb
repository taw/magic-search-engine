describe "Modal cards" do
  include_context "db"

  it "is:modal" do
    assert_search_equal "is:modal", %[o:/(choose|opponent chooses) .*\n•/]
    assert_search_equal "not:modal", "-(is:modal)"
  end
end

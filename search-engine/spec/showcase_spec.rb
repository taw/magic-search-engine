describe "Showcase" do
  include_context "db"

  it "is:showcase" do
    assert_search_equal "is:showcase", "frame:showcase"
  end

  it "has:showcase" do
    assert_search_equal "e:one has:showcase", "e:one alt:(e:one is:showcase)"
  end
end

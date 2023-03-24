describe "Boosterfun" do
  include_context "db"

  it "is:boosterfun" do
    assert_search_equal "is:boosterfun", "(-is:foilonly (is:showcase or is:borderless))"
  end

  it "has:boosterfun" do
    assert_search_equal "e:one has:boosterfun", "e:one alt:(e:one (is:showcase or is:borderless) -is:foilonly)"
  end
end

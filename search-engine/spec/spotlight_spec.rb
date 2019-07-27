describe "Story Spotlight cards" do
  include_context "db"

  it "is:spotlight" do
    assert_search_results "is:spotlight e:dom",
      "Broken Bond",
      "Final Parting",
      "In Bolas's Clutches",
      "Settle the Score"

    assert_search_equal "not:spotlight", "-(is:spotlight)"
  end
end

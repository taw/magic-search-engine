describe "Modal cards" do
  include_context "db"

  it "is:modal" do
    assert_search_equal "is:modal", %[o:/(choose|opponent chooses) .*\n•/ or kw:spree or kw:tiered]
    assert_search_equal "not:modal", "-(is:modal)"
  end

  # CR 702.172a and 702.183a both say the ability is found on modal spells, but the
  # cards only say so in reminder text, which is not part of the text we search
  it "spree and tiered spells are modal" do
    assert_search_equal "kw:spree", "kw:spree is:modal"
    assert_search_equal "kw:tiered", "kw:tiered is:modal"
    assert_search_include "is:modal",
      "Caught in the Crossfire",
      "Three Steps Ahead",
      "Cloud's Limit Break",
      "Vincent's Limit Break"
  end
end

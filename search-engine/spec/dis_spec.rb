describe "DissentionTest" do
  include_context "db", "dis"

  it "Transguild Courier" do
    "c:wubrg"   .should include_cards "Transguild Courier"
    "c!wubrg"   .should include_cards "Transguild Courier"
    "ci:wubrg"  .should include_cards "Transguild Courier"
    # This got errata to vanilla with indicator, then back
    "is:vanilla".should return_no_cards
  end
end

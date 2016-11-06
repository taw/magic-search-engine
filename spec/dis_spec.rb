describe "DissentionTest" do
  include_context "db", "di"

  it "Transguild Courier" do
    "c:wubrg"   .should include_cards "Transguild Courier"
    "c!wubrg"   .should include_cards "Transguild Courier"
    "ci:wubrg"  .should include_cards "Transguild Courier"
    "is:vanilla".should include_cards "Transguild Courier"
  end
end

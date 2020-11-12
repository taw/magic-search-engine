describe "XMage" do
  include_context "db"

  it "has almost all Modern legal cards" do
    # Only two from M19 Gift Pack missing last time I checked
    assert_search_results "f:modern -in:xmage",
      "Angler Turtle",
      "Vengeant Vampire"
  end
end

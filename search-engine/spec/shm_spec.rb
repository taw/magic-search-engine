describe "Shadowmoor" do
  include_context "db", "shm"

  it "2/x mana" do
    "mana>={2/b}".should return_cards "Beseech the Queen", "Reaper King"
  end

  # In addition to classic hybrid
  it "is:hybrid" do
      assert_search_equal "is:hybrid", "mana>={2/w} or mana>={2/u} or mana>={2/b} or mana>={2/r} or mana>={2/g}"
  end
end

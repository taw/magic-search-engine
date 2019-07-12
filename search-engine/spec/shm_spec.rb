describe "Shadowmoor" do
  include_context "db", "shm"

  it "2/x mana" do
    "mana>={2/b}".should return_cards "Beseech the Queen", "Reaper King"
  end

  # Works with both classic hybrid and 2-hybrid
  it "is:hybrid" do
      assert_search_equal "is:hybrid",
        "mana>={2/w} or mana>={2/u} or mana>={2/b} or mana>={2/r} or mana>={2/g} or
         mana>={u/w} or mana>={b/w} or mana>={r/w} or mana>={g/w} or mana>={b/u} or
         mana>={r/u} or mana>={g/u} or mana>={b/r} or mana>={b/g} or mana>={g/r}"
  end
end

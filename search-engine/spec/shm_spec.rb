describe "Shadowmoor" do
  include_context "db", "shm"

  it "2/x mana" do
    "mana>={2/b}".should return_cards "Beseech the Queen", "Reaper King"
  end
end

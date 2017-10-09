describe "Sets" do
  include_context "db"

  KNOWS_SET_TYPES = [
    "archenemy",
    "box",
    "commander",
    "conspiracy",
    "core",
    "duel deck",
    "expansion",
    "from the vault",
    "masterpiece",
    "masters",
    "planechase",
    "premium deck",
    "promo",
    "reprint",
    "starter",
    "un",
    "vanguard",
  ]

  it "all sets have sensible type" do
    db.sets.values.map(&:type).to_set.should eq KNOWS_SET_TYPES.to_set
  end
end

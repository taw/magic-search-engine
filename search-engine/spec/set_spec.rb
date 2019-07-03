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
    "funny",
    "masterpiece",
    "masters",
    "memorabilia",
    "modern",
    "planechase",
    "premium deck",
    "promo",
    "spellbook",
    "starter",
    "token",
    "treasure chest",
    "two-headed giant",
    "un",
    "vanguard",
  ]

  it "all sets have sensible type" do
    db.sets.values.map(&:type).sort.to_set.should eq KNOWS_SET_TYPES.to_set
  end
end

describe "Sets" do
  include_context "db"

  let(:known_set_types) do
    [
      "alchemy",
      "archenemy",
      "arena league",
      "arsenal",
      "booster",
      "box",
      "commander",
      "conspiracy",
      "core",
      "deck",
      "draft innovation",
      "duel deck",
      "duels",
      "expansion",
      "fixed",
      "fnm",
      "from the vault",
      "funny",
      "judge gift",
      "jumpstart",
      "masterpiece",
      "masters",
      "memorabilia",
      "modern",
      "multiplayer",
      "pioneer",
      "planechase",
      "player rewards",
      "portal",
      "premiere shop",
      "premium deck",
      "promo",
      "spellbook",
      "standard",
      "starter",
      "token",
      "treasure chest",
      "two-headed giant",
      "un",
      "vanguard",
    ].to_set
  end

  it "all sets have sensible type" do
    db.sets.values.flat_map(&:types).sort.to_set.should eq known_set_types
  end
end

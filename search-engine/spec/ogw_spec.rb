describe "Oath of Gatewatch" do
  include_context "db", "ogw"

  it "colorless mana is not generic mana" do
    card_6  = db.cards["kozilek's pathfinder"]
    card_5c = db.cards["endbringer"]
    ConditionMana.new("=", "6")   .should     be_match(card_6)
    ConditionMana.new("=", "6")   .should_not be_match(card_5c)
    ConditionMana.new("=", "5{c}").should_not be_match(card_6)
    ConditionMana.new("=", "5{c}").should     be_match(card_5c)
  end

  it "devoid doesn't affect color identity" do
    db.cards["abstruse interference"].color_identity.should eq("u")
    "ci:u".should include_cards "Abstruse Interference"
    "ci:c".should exclude_cards "Abstruse Interference"
  end
end

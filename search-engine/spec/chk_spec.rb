describe "Champions of Kamigawa" do
  include_context "db", "chk"

  it "is:split" do
    "is:split".should return_no_cards
    "is:dfc"  .should return_no_cards
    "is:flip" .should include_cards "Akki Lavarunner"
    "not:flip".should exclude_cards "Akki Lavarunner"
  end

  # 709.1c A flip card’s color and mana cost don’t change if the permanent is flipped. Also, any changes to it by external effects will still apply.
  # However it's really confusing to print that in card titleline, as it's not directly castable, so we hide it
  it "flip card mana cost" do
    "cmc=4"  .should include_cards "Kitsune Mystic", "Autumn-Tail, Kitsune Sage"
    "mana=3w".should include_cards "Kitsune Mystic", "Autumn-Tail, Kitsune Sage"
    db.search("is:flip mana=3w")
      .printings
      .map{|c| [c.name, c.mana_cost, c.display_mana_cost] }
      .should match_array [
        ["Autumn-Tail, Kitsune Sage", "{3}{w}", nil],
        ["Kitsune Mystic", "{3}{w}", "{3}{w}"],
      ]
  end

  it "is:primary" do
    "is:primary t:fox".should return_cards(
      "Eight-and-a-Half-Tails",
      "Kitsune Blademaster",
      "Kitsune Diviner",
      "Kitsune Healer",
      "Kitsune Mystic",
      "Kitsune Riftwalker",
      "Pious Kitsune",
      "Samurai of the Pale Curtain",
      "Sensei Golden-Tail"
    )
    "not:primary t:fox".should return_cards(
      "Autumn-Tail, Kitsune Sage"
    )
  end

  it "is:front" do
    "is:front".should equal_search "*"
  end

  it "is:commander" do
    "is:commander".should equal_search "is:primary t:legendary t:creature"
  end
end

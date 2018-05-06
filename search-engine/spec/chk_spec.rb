describe "Champions of Kamigawa" do
  include_context "db", "chk"

  it "is:split" do
    "is:split".should return_no_cards
    "is:dfc"  .should return_no_cards
    "is:flip" .should include_cards "Akki Lavarunner"
    "not:flip".should exclude_cards "Akki Lavarunner"
  end

  # 709.1c A flip card’s color and mana cost don’t change if the permanent is flipped. Also, any changes to it by external effects will still apply.
  it "flip card mana cost" do
    "cmc=4"  .should include_cards "Kitsune Mystic", "Autumn-Tail, Kitsune Sage"
    "mana=3w".should include_cards "Kitsune Mystic", "Autumn-Tail, Kitsune Sage"
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

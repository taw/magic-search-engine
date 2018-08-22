describe "Unsets" do
  include_context "db", "ust"
  # https://magic.wizards.com/en/articles/archive/news/unstable-variants-2017-12-06

  it "Amateur Auteur" do
    expect_numbers "Amateur Auteur ft:ravnica", "3A"
    expect_numbers "Amateur Auteur ft:innistrad", "3B"
    expect_numbers "Amateur Auteur ft:theros", "3C"
    expect_numbers "Amateur Auteur ft:zendikar", "3D"
  end

  it "Beast in Show" do
    expect_numbers "Beast in Show ft:plating", "103A"
    expect_numbers "Beast in Show ft:odor", "103B"
    expect_numbers "Beast in Show ft:baloth", "103C"
    expect_numbers "Beast in Show ft:curvature", "103D"
  end

  it "Everythingamajig" do
    expect_variant 'Everythingamajig o:"proliferate"', "Everythingamajig (a)", "147A"
    expect_variant 'Everythingamajig o:"10 life"', "Everythingamajig (b)", "147B"
    expect_variant 'Everythingamajig o:"flip a coin"', "Everythingamajig (c)", "147C"
    expect_variant 'Everythingamajig o:"12 damage"', "Everythingamajig (d)", "147D"
    expect_variant 'Everythingamajig o:"sacrifice a land"', "Everythingamajig (e)", "147E"
    expect_variant 'Everythingamajig o:"goat creature token"', "Everythingamajig (f)", "147F"
  end

  it "Extremely Slow Zombie" do
    expect_numbers "Extremely Slow Zombie ft:Brrrrrrrrrrrr", "54A"
    expect_numbers "Extremely Slow Zombie ft:aaaaaaiiii", "54B"
    expect_numbers "Extremely Slow Zombie ft:iiiiiiinnnn", "54C"
    expect_numbers "Extremely Slow Zombie ft:nnnnnssssss", "54D"
  end

  it "Garbage Elemental" do
    expect_variant 'Garbage Elemental o:"frenzy"', "Garbage Elemental (a)", "82A"
    expect_variant 'Garbage Elemental o:"undying"', "Garbage Elemental (b)", "82B"
    expect_variant 'Garbage Elemental o:"battle cry"', "Garbage Elemental (c)", "82C"
    expect_variant 'Garbage Elemental o:"cascade"', "Garbage Elemental (d)", "82D"
    expect_variant 'Garbage Elemental o:"unleash"', "Garbage Elemental (e)", "82E"
    expect_variant 'Garbage Elemental o:"last strike"', "Garbage Elemental (f)", "82F"
  end

  it "Ineffable Blessing" do
    expect_variant 'Ineffable Blessing o:"flavorful or bland"', "Ineffable Blessing (a)", "113A"
    expect_variant 'Ineffable Blessing o:"choose an artist"', "Ineffable Blessing (b)", "113B"
    expect_variant 'Ineffable Blessing o:"white-bordered"', "Ineffable Blessing (c)", "113C"
    expect_variant 'Ineffable Blessing o:"rarity"', "Ineffable Blessing (d)", "113D"
    expect_variant 'Ineffable Blessing o:"odd or even"', "Ineffable Blessing (e)", "113E"
    expect_variant 'Ineffable Blessing o:"choose a number"', "Ineffable Blessing (f)", "113F"
  end

  it "Killbots" do
    expect_variant "curious t:killbot", "Curious Killbot", "145A"
    expect_variant "delighted t:killbot", "Delighted Killbot", "145B"
    expect_variant "despondent t:killbot", "Despondent Killbot", "145C"
    expect_variant "enraged t:killbot", "Enraged Killbot", "145D"
    assert_count_cards "t:killbot", 4
  end

  it "Knight of the Kitchen Sink" do
    expect_variant 'Knight of the Kitchen Sink o:"black borders"', "Knight of the Kitchen Sink (a)", "12A"
    expect_variant 'Knight of the Kitchen Sink o:"even collector numbers"', "Knight of the Kitchen Sink (b)", "12B"
    expect_variant 'Knight of the Kitchen Sink o:"loose lips"', "Knight of the Kitchen Sink (c)", "12C"
    expect_variant 'Knight of the Kitchen Sink o:"odd collector numbers"', "Knight of the Kitchen Sink (d)", "12D"
    expect_variant 'Knight of the Kitchen Sink o:"two-word names"', "Knight of the Kitchen Sink (e)", "12E"
    expect_variant 'Knight of the Kitchen Sink o:"watermarks"', "Knight of the Kitchen Sink (f)", "12F"
  end

  it "Novellamental" do
    expect_numbers "Novellamental ft:sold", "41A"
    expect_numbers "Novellamental ft:solitude", "41B"
    expect_numbers "Novellamental ft:silent", "41C"
    expect_numbers "Novellamental ft:specks", "41D"
  end

  it "Secret Base" do
    # Gatherer order is different than article order and we follow Gatherer
    expect_numbers "Secret Base w:sneak", "165A"
    expect_numbers "Secret Base w:widget", "165B"
    expect_numbers "Secret Base w:league", "165C"
    expect_numbers "Secret Base w:explosioneers", "165D"
    expect_numbers "Secret Base w:crossbreed", "165E"
  end

  it "Sly Spy" do
    expect_numbers "Sly Spy ft:serious", "67A"
    expect_numbers "Sly Spy ft:ninjas", "67B"
    expect_numbers "Sly Spy ft:nerds", "67C"
    expect_numbers "Sly Spy ft:kickers", "67D"
    expect_numbers "Sly Spy ft:spies", "67E"
    expect_numbers "Sly Spy ft:evil", "67F"
  end

  # Only differs in art, so this test doesn't do much
  it "Target Minotaur" do
    expect_numbers 'Target Minotaur ft:"not again"', "98A", "98B", "98C", "98D"
  end

  it "Very Cryptic Command" do
    # Well, this is reversed, let's just live with it
    expect_variant 'Very Cryptic Command o:"wayne england"', "Very Cryptic Command (a)", "49B"
    expect_variant 'Very Cryptic Command o:"exactly one word"', "Very Cryptic Command (b)", "49A"
    expect_variant 'Very Cryptic Command o:"blue frog"', "Very Cryptic Command (c)", "49C"
    expect_variant 'Very Cryptic Command o:"turn over"', "Very Cryptic Command (d)", "49D"
    expect_variant 'Very Cryptic Command o:"roll two"', "Very Cryptic Command (e)", "49E"
    expect_variant 'Very Cryptic Command o:"black rogue"', "Very Cryptic Command (f)", "49F"
  end

  def expect_variant(query, full_name, number)
    results = db.search(query).printings
    results.size.should eq(1)
    results[0].name.should eq(full_name)
    results[0].number.should eq(number)
  end

  def expect_numbers(query, *numbers)
    actual_numbers = db.search(query).printings.map(&:number)
    actual_numbers.should match_array(numbers)
  end
end

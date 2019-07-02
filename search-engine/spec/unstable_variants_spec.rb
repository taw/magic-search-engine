describe "Unsets" do
  include_context "db", "ust"
  # https://magic.wizards.com/en/articles/archive/news/unstable-variants-2017-12-06

  it "Amateur Auteur" do
    expect_numbers "Amateur Auteur ft:ravnica", "3a"
    expect_numbers "Amateur Auteur ft:innistrad", "3b"
    expect_numbers "Amateur Auteur ft:theros", "3c"
    expect_numbers "Amateur Auteur ft:zendikar", "3d"
  end

  it "Beast in Show" do
    expect_numbers "Beast in Show ft:plating", "103a"
    expect_numbers "Beast in Show ft:odor", "103b"
    expect_numbers "Beast in Show ft:baloth", "103c"
    expect_numbers "Beast in Show ft:curvature", "103d"
  end

  it "Everythingamajig" do
    expect_variant 'Everythingamajig o:"proliferate"', "Everythingamajig (a)", "147a"
    expect_variant 'Everythingamajig o:"10 life"', "Everythingamajig (b)", "147b"
    expect_variant 'Everythingamajig o:"flip a coin"', "Everythingamajig (c)", "147c"
    expect_variant 'Everythingamajig o:"12 damage"', "Everythingamajig (d)", "147d"
    expect_variant 'Everythingamajig o:"sacrifice a land"', "Everythingamajig (e)", "147e"
    expect_variant 'Everythingamajig o:"goat creature token"', "Everythingamajig (f)", "147f"
  end

  it "Extremely Slow Zombie" do
    expect_numbers "Extremely Slow Zombie ft:Brrrrrrrrrrrr", "54a"
    expect_numbers "Extremely Slow Zombie ft:aaaaaaiiii", "54b"
    expect_numbers "Extremely Slow Zombie ft:iiiiiiinnnn", "54c"
    expect_numbers "Extremely Slow Zombie ft:nnnnnssssss", "54d"
  end

  it "Garbage Elemental" do
    expect_variant 'Garbage Elemental o:"frenzy"', "Garbage Elemental (a)", "82a"
    expect_variant 'Garbage Elemental o:"undying"', "Garbage Elemental (b)", "82b"
    expect_variant 'Garbage Elemental o:"battle cry"', "Garbage Elemental (c)", "82c"
    expect_variant 'Garbage Elemental o:"cascade"', "Garbage Elemental (d)", "82d"
    expect_variant 'Garbage Elemental o:"unleash"', "Garbage Elemental (e)", "82e"
    expect_variant 'Garbage Elemental o:"last strike"', "Garbage Elemental (f)", "82f"
  end

  it "Ineffable Blessing" do
    expect_variant 'Ineffable Blessing o:"flavorful or bland"', "Ineffable Blessing (a)", "113a"
    expect_variant 'Ineffable Blessing o:"choose an artist"', "Ineffable Blessing (b)", "113b"
    expect_variant 'Ineffable Blessing o:"white-bordered"', "Ineffable Blessing (c)", "113c"
    expect_variant 'Ineffable Blessing o:"rarity"', "Ineffable Blessing (d)", "113d"
    expect_variant 'Ineffable Blessing o:"odd or even"', "Ineffable Blessing (e)", "113e"
    expect_variant 'Ineffable Blessing o:"choose a number"', "Ineffable Blessing (f)", "113f"
  end

  it "Killbots" do
    expect_variant "curious t:killbot", "Curious Killbot", "145a"
    expect_variant "delighted t:killbot", "Delighted Killbot", "145b"
    expect_variant "despondent t:killbot", "Despondent Killbot", "145c"
    expect_variant "enraged t:killbot", "Enraged Killbot", "145d"
    assert_count_cards "t:killbot", 4
  end

  it "Knight of the Kitchen Sink" do
    expect_variant 'Knight of the Kitchen Sink o:"black borders"', "Knight of the Kitchen Sink (a)", "12a"
    expect_variant 'Knight of the Kitchen Sink o:"even collector numbers"', "Knight of the Kitchen Sink (b)", "12b"
    expect_variant 'Knight of the Kitchen Sink o:"loose lips"', "Knight of the Kitchen Sink (c)", "12c"
    expect_variant 'Knight of the Kitchen Sink o:"odd collector numbers"', "Knight of the Kitchen Sink (d)", "12d"
    expect_variant 'Knight of the Kitchen Sink o:"two-word names"', "Knight of the Kitchen Sink (e)", "12e"
    expect_variant 'Knight of the Kitchen Sink o:"watermarks"', "Knight of the Kitchen Sink (f)", "12f"
  end

  it "Novellamental" do
    expect_numbers "Novellamental ft:sold", "41a"
    expect_numbers "Novellamental ft:solitude", "41b"
    expect_numbers "Novellamental ft:silent", "41c"
    expect_numbers "Novellamental ft:specks", "41d"
  end

  it "Secret Base" do
    # This differs from Gatherer order
    expect_numbers "Secret Base w:widget", "165a"
    expect_numbers "Secret Base w:sneak", "165b"
    expect_numbers "Secret Base w:league", "165c"
    expect_numbers "Secret Base w:explosioneers", "165d"
    expect_numbers "Secret Base w:crossbreed", "165e"
  end

  it "Sly Spy" do
    expect_numbers "Sly Spy ft:serious", "67a"
    expect_numbers "Sly Spy ft:ninjas", "67b"
    expect_numbers "Sly Spy ft:nerds", "67c"
    expect_numbers "Sly Spy ft:kickers", "67d"
    expect_numbers "Sly Spy ft:spies", "67e"
    expect_numbers "Sly Spy ft:evil", "67f"
  end

  # Only differs in art, so this test doesn't do much
  it "Target Minotaur" do
    expect_numbers 'Target Minotaur ft:"not again"', "98a", "98b", "98c", "98d"
  end

  it "Very Cryptic Command" do
    # This differs between sources
    expect_variant 'Very Cryptic Command o:"wayne england"', "Very Cryptic Command (a)", "49a"
    expect_variant 'Very Cryptic Command o:"exactly one word"', "Very Cryptic Command (b)", "49b"
    expect_variant 'Very Cryptic Command o:"blue frog"', "Very Cryptic Command (c)", "49c"
    expect_variant 'Very Cryptic Command o:"turn over"', "Very Cryptic Command (d)", "49d"
    expect_variant 'Very Cryptic Command o:"roll two"', "Very Cryptic Command (e)", "49e"
    expect_variant 'Very Cryptic Command o:"black rogue"', "Very Cryptic Command (f)", "49f"
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

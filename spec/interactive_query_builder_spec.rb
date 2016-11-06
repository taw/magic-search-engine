describe "InteractiveQueryBuilder" do
  def assert_interactive_query(expected_query, *args)
    actual_query = InteractiveQueryBuilder.new(*args).query
    expected_query.should eq(actual_query)
  end

  it "name" do
    assert_interactive_query "dragon", name: "dragon"
    assert_interactive_query 'green dragon', name: "green dragon"
    assert_interactive_query '"green dragon"', name: '"green dragon"'
  end

  it "type" do
    assert_interactive_query "t:dragon", type: "dragon"
    assert_interactive_query 't:legendary t:dragon', type: "legendary dragon"
    assert_interactive_query 't:"legendary dragon"', type: '"legendary dragon"'
  end

  it "oracle" do
    assert_interactive_query "o:draw", oracle: "draw"
    assert_interactive_query 'o:draw o:three', oracle: "draw three"
    assert_interactive_query 'o:"draw three"', oracle: '"draw three"'
  end

  it "flavor" do
    assert_interactive_query "ft:fire", flavor: "fire"
    assert_interactive_query 'ft:on ft:fire', flavor: "on fire"
    assert_interactive_query 'ft:"on fire"', flavor: '"on fire"'
  end

  it "artist" do
    assert_interactive_query "a:argyle", artist: "argyle"
    assert_interactive_query 'a:steve a:argyle', artist: "steve argyle"
    assert_interactive_query 'a:"steve argyle"', artist: '"steve argyle"'
  end

  it "rarity" do
    assert_interactive_query "r:uncommon", rarity: ["uncommon"]
    assert_interactive_query "(r:mythic OR r:rare)", rarity: ["rare", "mythic"]
  end

  it "set" do
    assert_interactive_query "e:ktk", set: ["ktk"]
    assert_interactive_query "e:ktk,m10", set: ["ktk", "m10"]
  end

  it "block" do
    assert_interactive_query "b:isd", block: ["isd"]
    assert_interactive_query "b:bfz,zen", block: ["zen", "bfz"]
  end

  it "set_and_block" do
    assert_interactive_query "(b:isd OR e:zen)", block: ["isd"], set: ["zen"]
    assert_interactive_query "(b:isd OR e:nph,som)", block: ["isd"], set: ["som", "nph"]
    assert_interactive_query "(b:isd,zen OR e:nph,som)", block: ["isd", "zen"], set: ["som", "nph"]
  end

  it "watermark" do
    assert_interactive_query "w:boros", watermark: ["boros"]
    assert_interactive_query "(w:abzan OR w:izzet)", watermark: ["izzet", "abzan"]
    assert_interactive_query "-w:*", watermark: ["no"]
    assert_interactive_query "w:*", watermark: ["yes"]
  end
end

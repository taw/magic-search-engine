require_relative "test_helper"

class InteractiveQueryBuilderTest < Minitest::Test
  def assert_interactive_query(expected_query, *args)
    actual_query = InteractiveQueryBuilder.new(*args).query
    assert_equal expected_query, actual_query, args.to_s
  end

  def test_name
    assert_interactive_query "dragon", name: "dragon"
    assert_interactive_query 'green dragon', name: "green dragon"
    assert_interactive_query '"green dragon"', name: '"green dragon"'
  end

  def test_type
    assert_interactive_query "t:dragon", type: "dragon"
    assert_interactive_query 't:legendary t:dragon', type: "legendary dragon"
    assert_interactive_query 't:"legendary dragon"', type: '"legendary dragon"'
  end

  def test_oracle
    assert_interactive_query "o:draw", oracle: "draw"
    assert_interactive_query 'o:draw o:three', oracle: "draw three"
    assert_interactive_query 'o:"draw three"', oracle: '"draw three"'
  end

  def test_flavor
    assert_interactive_query "ft:fire", flavor: "fire"
    assert_interactive_query 'ft:on ft:fire', flavor: "on fire"
    assert_interactive_query 'ft:"on fire"', flavor: '"on fire"'
  end

  def test_artist
    assert_interactive_query "a:argyle", artist: "argyle"
    assert_interactive_query 'a:steve a:argyle', artist: "steve argyle"
    assert_interactive_query 'a:"steve argyle"', artist: '"steve argyle"'
  end

  def test_rarity
    assert_interactive_query "r:uncommon", rarity: ["uncommon"]
    assert_interactive_query "(r:rare OR r:mythic)", rarity: ["rare", "mythic"]
  end

  def test_set
    assert_interactive_query "e:ktk", set: ["ktk"]
    assert_interactive_query "(e:ktk OR e:m10)", set: ["ktk", "m10"]
  end

  def test_block
    assert_interactive_query "b:isd", block: ["isd"]
    assert_interactive_query "(b:zen OR b:bfz)", block: ["zen", "bfz"]
  end

  def test_watermark
    assert_interactive_query "w:boros", watermark: ["boros"]
    assert_interactive_query "(w:izzet OR w:abzan)", watermark: ["izzet", "abzan"]
  end
end

require_relative "test_helper"

class InteractiveQueryBuilderTest < Minitest::Test
  def assert_interactive_query(expected_query, *args)
    actual_query = InteractiveQueryBuilder.new(*args).query
    assert_equal expected_query, actual_query, args.to_s
  end

  def test_any
    assert_interactive_query "*:dragon", any: "dragon"
    assert_interactive_query '*:green *:dragon', any: "green dragon"
    assert_interactive_query '*:"green dragon"', any: '"green dragon"'
  end

  def test_title
    assert_interactive_query "dragon", title: "dragon"
    assert_interactive_query 'green dragon', title: "green dragon"
    assert_interactive_query '"green dragon"', title: '"green dragon"'
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
end

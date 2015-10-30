require_relative "test_helper"

class CardQueryParser < Minitest::Test
  # Needs some negative tests...
  def test_parsing_basics
    assert_search_parse "r:common alt:r:uncommon", "r:common alt:(r:uncommon)"
    assert_search_parse "cmc=1 c:w", "cmc=1 AND c:w"
    assert_search_parse "cmc=1 c:w", "CMC=1 C:W"
  end

  def test_structural_equivalence
    assert_search_parse "cmc=1 c:w", "(cmc=1 (c:w))"
    assert_search_parse "cmc=1 c:w", "cmc=1 -(-c:w)"
    assert_search_parse "(cmc=1 c:w) r:common", "cmc=1 (c:w r:common)"
  end
end

require_relative "test_helper"

class CardQueryParser < Minitest::Test
  def test_parsing_basics
    assert_search_parse "r:common alt:r:uncommon", "r:common alt:(r:uncommon)"
    assert_search_parse "cmc=1 c:w", "cmc=1 AND c:w"
    refute_search_parse "cmc=1 OR c:w", "cmc=1 AND c:w"
    assert_search_parse "cmc=1 c:w", "CMC=1 C:W"
  end

  def test_structural_equivalence
    assert_search_parse "cmc=1 c:w", "(cmc=1 (c:w))"
    assert_search_parse "(cmc=1 c:w) r:common", "cmc=1 (c:w r:common)"
    # Would be nice if this worked, doesn't work yet
    refute_search_parse "cmc=1 c:w", "cmc=1 -(-c:w)"
    refute_search_parse "cmc=1 c:w", "c:w cmc=1"
    refute_search_parse "c:uw", "c:wu"
  end

  def test_time
    refute_search_parse "time:2010", "time:2011 r:common"
    assert_search_parse %Q[time:2010 r:common], %Q[time:2010.1.1 r:common]
    assert_search_parse %Q[time:2010.3.3 r:common], %Q[time:"3 march 2010" r:common]
    assert_search_parse %Q[time:2010.3 r:common], %Q[time:"1 march 2010" r:common]
    assert_search_parse %Q[time:rtr r:common], %Q[time:RTR r:common]
  end
end

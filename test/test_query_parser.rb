require "pp"

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

  def test_query_to_s
    query_examples = (Pathname(__dir__) + "query_examples.txt").readlines.map(&:chomp)

    fails = 0

    query_examples.each do |query_string|
      query = Query.new(query_string)
      query_string_2 = query.to_s
      query_2 = Query.new(query_string_2)

      # It should simply be, but it's better to have extra feedback:
      # assert_equal query, query_2, query_string


      if query != query_2
        fails += 1
        pp [:mismatch, query_string, query, query_string_2, query_2]
      elsif query_string != query_string_2
        # p [:partial, query_string, query, query_string_2]
        assert_equal query, query_2
      else
        # p [:perfect, query_string, query]
        assert_equal query, query_2
      end
    end

    assert_equal 0, fails, "Total fails: #{fails}"
  end
end

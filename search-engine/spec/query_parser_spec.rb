describe "QueryParser" do
  def assert_search_parse(query1, query2)
    Query.new(query1).should eq(Query.new(query2))
  end

  def refute_search_parse(query1, query2)
    Query.new(query1).should_not eq(Query.new(query2))
  end

  it "parsing_basics" do
    assert_search_parse "r:common alt:r:uncommon", "r:common alt:(r:uncommon)"
    assert_search_parse "cmc=1 c:w", "cmc=1 AND c:w"
    refute_search_parse "cmc=1 OR c:w", "cmc=1 AND c:w"
    assert_search_parse "cmc=1 c:w", "CMC=1 C:W"
  end

  it "structural_equivalence" do
    assert_search_parse "cmc=1 c:w", "(cmc=1 (c:w))"
    assert_search_parse "(cmc=1 c:w) r:common", "cmc=1 (c:w r:common)"
    # Would be nice if this worked, doesn't work yet
    refute_search_parse "cmc=1 c:w", "cmc=1 -(-c:w)"
    assert_search_parse "cmc=1 c:w", "c:w cmc=1"
    assert_search_parse "cmc=1 OR c:w", "c:w OR cmc=1"
    refute_search_parse "c:uw", "c:wu"
    refute_search_parse "ci:uw", "ci!wu"
  end

  it ": and = equivalence" do
    assert_search_parse "o:/foo/", "O:/foo/"
    refute_search_parse "o:/foo/", "o:/FOO/"
    assert_search_parse "t:goblin", "t=goblin"
    assert_search_parse "ft:goblin", "ft=goblin"
    assert_search_parse "o:goblin", "o=goblin"
    assert_search_parse "a:goblin", "a=goblin"
    assert_search_parse "fr:goblin", "fr=goblin"
    assert_search_parse "banned:modern", "banned=modern"
    assert_search_parse "legal:modern", "legal=modern"
    assert_search_parse "restricted:modern", "restricted=modern"
    assert_search_parse "f:modern", "f=modern"
    assert_search_parse "e:isd", "e=isd"
    assert_search_parse "b:isd", "b=isd"
    assert_search_parse "w:abzan", "w=abzan"
    assert_search_parse "st:core", "st=core"
    assert_search_parse "in:g", "in=g"
    assert_search_parse "print=m10", "print:m10"
    assert_search_parse "firstprint=m10", "firstprint:m10"
    assert_search_parse "lastprint=m10", "lastprint:m10"
    assert_search_parse "r:rare", "r=rare"
    assert_search_parse "pow=5", "pow:5"
    assert_search_parse "tou=5", "tou:5"
    assert_search_parse "cmc=5", "cmc:5"
    assert_search_parse "loy=5", "loy:5"
    assert_search_parse "year=2000", "year:2000"
    assert_search_parse "pow=5", "power=5"
    assert_search_parse "tou=5", "toughness=5"
    assert_search_parse "loy=5", "loyalty=5"
    assert_search_parse "pow=toughness", "power=tou"
    assert_search_parse "toughness=pow", "tou=power"
    assert_search_parse "cmc=loyalty", "cmc=loy"
    assert_search_parse "mana=2u", "mana:2u"
    assert_search_parse "m=2u", "m:2u"
    assert_search_parse "mana=2u", "m=2u"
    assert_search_parse "is:fetchland", "is=fetchland"
    assert_search_parse "is:split", "is=split"
    assert_search_parse "layout:scheme", "layout=scheme"
    assert_search_parse "is:future", "is=future"
    assert_search_parse "not:future", "not=future"
    assert_search_parse "frame:future", "frame=future"
    assert_search_parse "is:silver-bordered", "is=silver-bordered"
    assert_search_parse "not:silver-bordered", "not=silver-bordered"
    assert_search_parse "border:black", "border=black"
    assert_search_parse "sort:new", "sort=new"
    assert_search_parse "view:images", "view=images"
    assert_search_parse "time:2012", "time=2012"
    assert_search_parse "other:t:planeswalker", "other=t=planeswalker"
    assert_search_parse "part:t:planeswalker", "part=t=planeswalker"
    assert_search_parse "related:t:planeswalker", "related=t=planeswalker"
    assert_search_parse "alt:t:planeswalker", "alt=t=planeswalker"
  end

  it "limits to : and = equivalence" do
    refute_search_parse "c:g", "c=g"
    refute_search_parse "ci:g", "ci=g"
    refute_search_parse "id:g", "id=g"
  end

  it "time" do
    refute_search_parse "time:2010", "time:2011 r:common"
    assert_search_parse %Q[time:2010 r:common], %Q[time:2010.1.1 r:common]
    assert_search_parse %Q[time:2010.3.3 r:common], %Q[time:"3 march 2010" r:common]
    assert_search_parse %Q[time:2010.3 r:common], %Q[time:"1 march 2010" r:common]
    assert_search_parse %Q[time:rtr r:common], %Q[time:RTR r:common]
  end

  it "query_to_s" do
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
        query.should eq query_2
      else
        # p [:perfect, query_string, query]
        query.should eq query_2
      end
    end

    fails.should eq(0)
  end
end

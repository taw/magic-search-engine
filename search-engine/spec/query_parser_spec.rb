describe "QueryParser" do
  def assert_search_parse(query1, query2)
    Query.new(query1).should eq(Query.new(query2))
  end

  def assert_search_parse_except_warning(query1, query2)
    q1 = Query.new(query1)
    q2 = Query.new(query2)
    q1.should_not eq(q2)
    q1.warnings.should_not eq(q2.warnings)
    q1.cond.should eq(q2.cond)
    q1.metadata.should eq(q2.metadata)
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
    # assert_search_parse "t:goblin", "t=goblin" # used to be true, but no longer true
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
    assert_search_parse "ind:g", "ind=g"
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
    assert_search_parse "other:t:planeswalker", "other=t:planeswalker"
    assert_search_parse "part:t:planeswalker", "part=t:planeswalker"
    assert_search_parse "related:t:planeswalker", "related=t:planeswalker"
    assert_search_parse "alt:t:planeswalker", "alt=t:planeswalker"
  end

  it "limits to : and = equivalence" do
    refute_search_parse "c:g", "c=g"
    refute_search_parse "ci:g", "ci=g"
    refute_search_parse "id:g", "id=g"
  end

  it "spaces around operators" do
    assert_search_parse "tou:5", "tou: 5"
    assert_search_parse "cmc:5", "cmc : 5"
    assert_search_parse "pow=5", "pow = 5"
    assert_search_parse "ci>=3", "ci >= 3"
    assert_search_parse "ci<=3", "ci <= 3"
    assert_search_parse "t:dragon", "t: dragon"
  end

  it "time" do
    refute_search_parse "time:2010", "time:2011 r:common"
    assert_search_parse %[time:2010 r:common], %[time:2010.1.1 r:common]
    assert_search_parse %[time:2010.3.3 r:common], %[time:"3 march 2010" r:common]
    assert_search_parse %[time:2010.3 r:common], %[time:"1 march 2010" r:common]
    assert_search_parse %[time:rtr r:common], %[time:RTR r:common]
  end

  it "color aliases with =" do
    # Single colors
    assert_search_parse "c=w", "c=white"
    assert_search_parse "c=u", "c=blue"
    assert_search_parse "c=b", "c=black"
    assert_search_parse "c=r", "c=red"
    assert_search_parse "c=g", "c=green"
    # Guilds
    assert_search_parse "c=wu", "c=azorius"
    assert_search_parse "c=ub", "c=dimir"
    assert_search_parse "c=br", "c=rakdos"
    assert_search_parse "c=rg", "c=gruul"
    assert_search_parse "c=gw", "c=selesnya"
    assert_search_parse "c=wr", "c=boros"
    assert_search_parse "c=ug", "c=simic"
    assert_search_parse "c=bw", "c=orzhov"
    assert_search_parse "c=ru", "c=izzet"
    assert_search_parse "c=gb", "c=golgari"
    # Shards
    assert_search_parse "c=gwu", "c=bant"
    assert_search_parse "c=wub", "c=esper"
    assert_search_parse "c=ubr", "c=grixis"
    assert_search_parse "c=brg", "c=jund"
    assert_search_parse "c=rgw", "c=naya"
    # Wedges
    assert_search_parse "c=wbg", "c=abzan"
    assert_search_parse "c=urw", "c=jeskai"
    assert_search_parse "c=bgu", "c=sultai"
    assert_search_parse "c=rwb", "c=mardu"
    assert_search_parse "c=gur", "c=temur"
    # Triomes
    assert_search_parse "c=wbg", "c=indatha"
    assert_search_parse "c=gur", "c=ketria"
    assert_search_parse "c=urw", "c=raugrin"
    assert_search_parse "c=rwb", "c=savai"
    assert_search_parse "c=bgu", "c=zagoth"

    assert_search_parse "ci=b", "ci=black"
    assert_search_parse "ci=gwu", "ci=bant"
    assert_search_parse "c>=w", "c>=white"
    assert_search_parse "ind=r", "ind=red"
    assert_search_parse "ind=wu", "ind=azorius"
  end

  # All the weird MCI logic, but only with MCI color names
  it "color aliases with :" do
    # Single colors
    assert_search_parse "c:w", "c>=white"
    assert_search_parse "c:u", "c>=blue"
    assert_search_parse "c:b", "c>=black"
    assert_search_parse "c:r", "c>=red"
    assert_search_parse "c:g", "c>=green"
    # Guilds
    assert_search_parse "c:wu", "c>=azorius"
    assert_search_parse "c:ub", "c>=dimir"
    assert_search_parse "c:br", "c>=rakdos"
    assert_search_parse "c:rg", "c>=gruul"
    assert_search_parse "c:gw", "c>=selesnya"
    assert_search_parse "c:wr", "c>=boros"
    assert_search_parse "c:ug", "c>=simic"
    assert_search_parse "c:bw", "c>=orzhov"
    assert_search_parse "c:ru", "c>=izzet"
    assert_search_parse "c:gb", "c>=golgari"
    # Shards
    assert_search_parse "c:gwu", "c>=bant"
    assert_search_parse "c:wub", "c>=esper"
    assert_search_parse "c:ubr", "c>=grixis"
    assert_search_parse "c:brg", "c>=jund"
    assert_search_parse "c:rgw", "c>=naya"
    # Wedges
    assert_search_parse "c:wbg", "c>=abzan"
    assert_search_parse "c:urw", "c>=jeskai"
    assert_search_parse "c:bgu", "c>=sultai"
    assert_search_parse "c:rwb", "c>=mardu"
    assert_search_parse "c:gur", "c>=temur"
    # Triomes
    assert_search_parse "c:wbg", "c>=indatha"
    assert_search_parse "c:gur", "c>=ketria"
    assert_search_parse "c:urw", "c>=raugrin"
    assert_search_parse "c:rwb", "c>=savai"
    assert_search_parse "c:bgu", "c>=zagoth"

    assert_search_parse "ci:b", "ci<=black"
    assert_search_parse "ci:gwu", "ci<=bant"
    assert_search_parse "c!u", "c!blue"
  end

  # These could be handled by parser or somewhere else
  it "aliases" do
    assert_search_parse "a:daarken", "art:daarken"
    assert_search_parse "a:daarken", "artist:daarken"
    assert_search_parse "a:/daarken/", "art:/daarken/"
    assert_search_parse "a:/daarken/", "artist:/daarken/"
    assert_search_parse_except_warning "a:/daa(rken/", "art:/daa(rken/"
    assert_search_parse_except_warning "a:/daa(rken/", "artist:/daa(rken/"
    assert_search_parse "b:zen", "block:zen"
    assert_search_parse "border:borderless", "border:none"
    assert_search_parse "border:borderless", "is:borderless"
    assert_search_parse "c:red", "color:red"
    assert_search_parse "c>red", "color>red"
    assert_search_parse "c:wu", "color:wu"
    assert_search_parse "c>wu", "color>wu"
    assert_search_parse "c=3", "color=3"
    assert_search_parse "e:m12", "set:m12"
    assert_search_parse "e:m12", "edition:m12"
    assert_search_parse "f:modern", "format:modern"
    assert_search_parse %[ft:"here's some gold"], %[flavor:"here's some gold"]
    assert_search_parse %[ft:/here's some gold/], %[flavor:/here's some gold/]
    assert_search_parse_except_warning %[ft:/here's (some gold/], %[flavor:/here's (some gold/]
    assert_search_parse "id:wu", "identity:wu"
    assert_search_parse "id<=wu", "identity<=wu"
    assert_search_parse "id:3", "identity:3"
    assert_search_parse "ind:wu", "indicator:wu"
    assert_search_parse "ind<wu", "indicator<wu"
    assert_search_parse "ind=3", "indicator=3"
    assert_search_parse "ind:*", "indicator:*"
    assert_search_parse "is:double-faced", "is:dfc"
    assert_search_parse "is:single-faced", "is:sfc"
    assert_search_parse "mana:2ww", "m:2ww"
    assert_search_parse 'o:"draw a card"', 'oracle:"draw a card"'
    assert_search_parse 'o:/draw \d+ cards/', 'oracle:/draw \d+ cards/'
    assert_search_parse_except_warning 'o:/draw ( card/', 'oracle:/draw ( card/'
    assert_search_parse "r>=uncommon", "rarity>=uncommon"
    assert_search_parse "r:rare", "rarity:rare"
    assert_search_parse "sort:cmc", "order:cmc"
    assert_search_parse "t:goblin", "type:goblin"
    assert_search_parse "view:full", "display:full"
    assert_search_parse "w:abzan", "wm:abzan"
    assert_search_parse "w:abzan", "watermark:abzan"
  end

  it "++" do
    assert_search_parse "++ pow=3 tou=2 c:g", "pow=3 tou=2 c:g ++"
    assert_search_parse "++ pow=3 tou=2 c:g", "pow=3 ++ tou=2 c:g"
    assert_search_parse "++ c:g //", "c:g // ++"
    # FIXME: This is a bug, just documenting so it can get fixed someday
    proc { Query.new("c:g ++ //") }.should raise_error(/Unknown token type/)
  end

  it "accepts alternative quotation marks" do
    assert_search_parse %Q[subset:"monster movie marathon"], %Q[subset:“monster movie marathon”]
  end

  it "query_to_s" do
    query_examples = (Pathname(__dir__) + "query_examples.txt").readlines.map(&:chomp)

    fails = 0

    query_examples.each do |query_string|
      query = Query.new(query_string)
      query_string_2 = query.to_s
      query_2 = Query.new(query_string_2)

      # These can't work due to the way things are setup
      next unless query.warnings.grep(/bad regular expression/).empty?

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

  it "warns for bad sort:" do
    Query.new('sort:awesomeness').warnings.should eq(["Unknown sort order: awesomeness. Known options are: artist, ci, cmc, color, default, firstprint, lastprint, mv, name, new, newall, number, old, oldall, pow, power, rand, random, rarity, released, set, tou, toughness; and their combinations."])
  end

  it "warns for bad view:" do
    Query.new('view:cardback').warnings.should eq(["Unknown view: cardback. Known options are: checklist, full, images, text, and default."])
  end

  it "warns for bad frame:" do
    Query.new('frame:pokemon').warnings[0].should match(/Unknown frame: pokemon/)
  end

  it "warns for bad layout:" do
    Query.new('layout:pokemon').warnings[0].should match(/Unknown layout: pokemon/)
  end
end

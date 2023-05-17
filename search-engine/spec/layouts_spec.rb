describe "Card layouts" do
  include_context "db"

  let(:layouts) { db.printings.map(&:layout).uniq }

  it "every layout has corresending layout: operator" do
    layouts.each do |layout|
      assert_search_results "layout:#{layout}",
        *cards_matching{|c| c.layout == layout}
    end
  end

  it "every layout: also works as is:" do
    layouts.each do |layout|
      assert_search_equal "layout:#{layout}", "is:#{layout}"
    end
  end

  it "is:dfc" do
    assert_search_equal "is:dfc", "layout:transform or layout:mdfc or layout:meld"
    assert_search_equal "is:sfc", "-is:dfc"
    assert_search_equal "is:sfc", "is:single-faced"
    assert_search_equal "is:dfc", "is:double-faced"
  end

  it "rules" do
    # These rules are mostly here to detect mtgjson errors
    # It's totally possible that a card will get printed which does not follow them
    assert_search_equal "layout:scheme", "t:scheme"
    assert_search_equal "layout:planar", "t:plane or t:phenomenon"
    assert_search_equal "layout:flip", '// o:"flip it" or o:"flip ~" or o:flipped or o:"Fire Penguin"'
    assert_search_equal "layout:vanguard", "t:vanguard"
    assert_search_equal "layout:split", "((t:instant or t:sorcery) // (t:instant or t:sorcery)) -(// o:aftermath)"
    assert_search_equal "layout:aftermath", "// o:aftermath"
    assert_search_equal "layout:leveler", 'o:/level up \{/'
    assert_search_equal "layout:meld", "// (// o:meld)"
    assert_search_equal "layout:saga -e:prm,mom", "t:saga -e:neo,pneo,prm,mom,pmom" # DFC sagas?
    assert_search_equal "layout:adventure", "t:adventure or (// t:adventure)"
    assert_search_equal "layout:modaldfc -e:pmei,slu,j21,prm,sld,pctb", "// e:znr,pznr,khm,pkhm,stx,pstx"

    # Alias
    assert_search_equal "layout:mdfc", "layout:modaldfc"
    assert_search_equal "layout:mdfc", "layout:modal-dfc"

    # No longer true since they got merged in v4,
    # we keep aliases but they're not exact
    assert_search_equal "layout:plane", "layout:planar"
    assert_search_equal "layout:phenomenon", "layout:planar"
  end

  it "is:vertical" do
    assert_search_equal "is:vertical", "not:horizontal"
  end

  it "is:horizontal" do
    assert_search_equal "is:horizontal", "t:battle or t:plane or t:phenomenon"
  end
end

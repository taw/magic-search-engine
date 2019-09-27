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

  it "layout aliases" do
    assert_search_equal "is:dfc", "layout:dfc"
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
    assert_search_equal "layout:saga", "t:saga"
    assert_search_equal "layout:adventure", "t:adventure or (// t:adventure)"

    # No longer true since they got merged in v4,
    # we keep aliases but they're not exact
    assert_search_equal "layout:plane", "layout:planar"
    assert_search_equal "layout:phenomenon", "layout:planar"
  end
end

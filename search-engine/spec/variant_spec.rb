# It would be great if mtgjson provided this data, and I didn't need to do the regexping
describe "Variant spec" do
  include_context "db"

  it "variant:misprint" do
    # inv is a misplaced promo due to bad mtgjson data
    # arn † are on same print sheets as regular versions and are in normal packs so they're not currently marked
    #   (they could be considered misprints)
    # mid and znr † are variant:arena
    assert_search_equal "variant:misprint", "(number:/†/ -e:arn,mid,znr) or (e:gpt,stx,inv,mkm number:/★/)"
  end

  it "variant:foreign" do
    assert_search_equal "variant:foreign", "((e:por or st:standard) number:/.s/) or (e:war number:/★/) or (e:sta number>=64) or (e:iko number:385-387)"
  end

  it "variant:arena" do
    assert_search_equal "variant:arena", "game:arena -game:paper -game:mtgo -is:alchemy (e:ktk,iko,mid,znr,spg)"
  end

  it "variant:arena does not overlap other variants" do
    assert_search_results "variant:arena (variant:misprint or variant:foreign)"
  end

  it "is:baseset" do
    assert_search_equal "is:baseset", "number:1-set -variant:misprint -variant:foreign -variant:arena"
  end
end

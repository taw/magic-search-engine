# It would be great if mtgjson provided this data, and I didn't need to do the regexping
describe "Variant spec" do
  include_context "db"

  it "variant:misprint" do
    # inv is really a misplaced promo due to bad mtgjson data
    assert_search_equal "variant:misprint", "(number:/†/ -e:arn) or (e:gpt,stx,inv number:/★/)"
  end

  it "variant:foreign" do
    assert_search_equal "variant:foreign", "((e:por or st:standard) number:/.s/) or (e:war number:/★/) or (e:sta number>=64) or (e:iko number:385-387)"
  end

  it "is:baseset" do
    assert_search_equal "is:baseset", "number:1-set -variant:misprint -variant:foreign"
  end
end

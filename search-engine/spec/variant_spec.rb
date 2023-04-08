# It would be great if mtgjson provided this data, and I didn't need to do the regexping
describe "Variant spec" do
  include_context "db"

  it "variant:misprint" do
    assert_search_equal "variant:misprint", "(number:/†/ -e:arn) or (e:gpt,stx number:/★/)"
  end

  it "variant:foreign" do
    assert_search_equal "variant:foreign", "((e:por or st:standard) number:/.s/) or (e:war number:/★/)"
  end
end

describe "Zendikar Rising" do
  include_context "db", "znr"

  it "Modal DFC cmc" do
    assert_search_results "t:land cmc>0"
    assert_search_results "is:modaldfc cmc=7",
      "Emeria's Call",
      "Sea Gate Restoration",
      "Turntimber Symbiosis"
  end
end

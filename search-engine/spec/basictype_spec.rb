describe "is:basictype" do
  include_context "db"

  it "is:basictype" do
    assert_search_equal "is:basictype", "t:plains or t:island or t:swamp or t:mountain or t:forest"
  end
end

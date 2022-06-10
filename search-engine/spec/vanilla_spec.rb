describe "Vanilla" do
  include_context "db"

  it "t:vanilla" do
    assert_search_equal "is:vanilla", "-o:/./ -t:forest -t:mountain -t:swamp -t:island -t:plains"
  end
end

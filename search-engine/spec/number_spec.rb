describe "number: queries" do
  include_context "db"

  it "<=set" do
    assert_search_equal "e:war number<=set", "e:war number<=264"
  end

  it ">set" do
    assert_search_equal "e:m20 number>set", "e:m20 number>set"
  end
end

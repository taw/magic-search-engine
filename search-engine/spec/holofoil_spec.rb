describe "is:holofoil" do
  include_context "db"

  it do
    # UST is exception to usual rules as full art basics have holofoil, but rare contraptions don't
    assert_search_equal "++ is:holofoil", "++ (r>=rare or (e:ust r:basic)) frame=m15 -t:contraption -is:back"
  end
end

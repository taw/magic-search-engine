describe "partner queries" do
  include_context "db"

  it "is:partner" do
    assert_search_equal "is:partner", %Q[(o:"partner with" e:bbd,pbbd,pz2,c20) OR (o:"partner" t:legendary t:creature e:c16,cm2,pz2)]
  end

  it "has:partner" do
    assert_search_equal "has:partner", %Q[o:"partner with" e:bbd,pbbd,c20]
  end
end

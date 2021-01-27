describe "partner queries" do
  include_context "db"

  it "is:partner" do
    assert_search_equal "is:partner", %[(o:"partner with" e:bbd,pbbd,pz2,c20,plist,cmr) OR (o:"partner" t:legendary t:creature e:c16,cm2,pz2,plist,cmr,htr18) or (o:"partner" t:legendary t:planeswalker e:cmr)]
  end

  it "has:partner" do
    assert_search_equal "has:partner", %[o:"partner with" e:bbd,pbbd,c20,plist,cmr]
  end
end

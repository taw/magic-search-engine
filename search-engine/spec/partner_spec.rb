describe "partner queries" do
  include_context "db"

  it "is:partner" do
    assert_search_equal "is:partner -e:prm,plist", %[(o:"partner with" e:bbd,pbbd,pz2,c20,cmr,voc,sld,clb) OR (o:"partner" t:legendary t:creature e:c16,cm2,pz2,cmr,htr18,khc,sld,nec,phed,unf,brc) or (o:"partner" t:legendary t:planeswalker e:cmr)]
  end

  it "has:partner" do
    assert_search_equal "has:partner -e:prm,plist", %[o:"partner with" e:bbd,pbbd,c20,cmr,voc,sld,clb]
  end
end

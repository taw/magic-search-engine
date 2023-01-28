describe "partner queries" do
  include_context "db"

  it "is:partner" do
    assert_search_equal "is:partner -is:promo", %[(o:"partner with" e:bbd,c20,cmr,voc,clb) OR (o:"partner" t:legendary t:creature e:c16,cm2,cmr,htr18,khc,nec,unf,brc,onc) or (o:"partner" t:legendary t:planeswalker e:cmr)]
  end

  it "has:partner" do
    assert_search_equal "has:partner -is:promo", %[o:"partner with" e:bbd,c20,cmr,voc,clb]
  end
end

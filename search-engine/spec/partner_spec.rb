describe "partner queries" do
  include_context "db"

  it "is:partner" do
    assert_search_equal "is:partner -is:promo -e:plst,prm", %[
      ((o:"partner with") or
       (o:"partner" t:legendary t:creature) or
       (o:"partner" t:legendary t:planeswalker e:cmr))
      -is:promo -e:plst,prm
    ]
  end

  it "has:partner" do
    assert_search_equal "has:partner -e:prm", %[o:"partner with" -e:prm -(Knight of Land Drops)]
  end
end

describe "partner queries" do
  include_context "db"

  it "is:partner" do
    assert_search_equal "is:partner -is:promo", %[
      ((o:"partner with") or
       (o:"partner" t:legendary t:creature) or
       (o:"partner" t:legendary t:planeswalker e:cmr))
      -is:promo
    ]
  end

  it "has:partner" do
    assert_search_equal "has:partner", %[o:"partner with"]
  end
end

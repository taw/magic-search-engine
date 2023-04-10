describe "is:phyrexian" do
  include_context "db"

  it "is:phyrexian" do
    # NPH had 5 types, then some new hybrid Phyrexian mana symbols showed up.
    # At some point we might see more types. Only listing known ones here.
    assert_search_equal "is:phyrexian", "mana>={wp} or mana>={up} or mana>={bp} or mana>={rp} or mana>={gp} or mana>={rwp} or mana>={gup} or mana>={gwp} or mana>={rgp}"
  end
end

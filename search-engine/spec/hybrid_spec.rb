describe "is:hybrid" do
  include_context "db"

  # A hybrid symbol is one which can be paid in more than one way.
  # At some point we might see more types. Only listing known ones here.
  it "is:hybrid" do
    assert_search_equal "is:hybrid",
      "mana>={u/w} or mana>={b/w} or mana>={r/w} or mana>={g/w} or mana>={b/u} or
       mana>={r/u} or mana>={g/u} or mana>={b/r} or mana>={b/g} or mana>={g/r} or
       mana>={2/w} or mana>={2/u} or mana>={2/b} or mana>={2/r} or mana>={2/g} or
       mana>={r/w/p} or mana>={g/u/p} or mana>={g/w/p} or mana>={r/g/p} or
       mana>={c/w} or mana>={c/u} or mana>={c/b} or mana>={c/r} or mana>={c/g}"
  end

  it "phyrexian hybrid is hybrid" do
    assert_search_results "is:hybrid is:phyrexian",
      "Ajani, Sleeper Agent",
      "Lukka, Bound to Ruin",
      "Nahiri, the Unforgiving",
      "Tamiyo, Compleated Sage"
  end

  it "colorless hybrid is hybrid" do
    assert_include_search "is:hybrid", "mana>={c/w}"
    assert_search_results "mana>={c/w}", "Ulalek, Fused Atrocity"
  end

  # {W/P} can only be paid one way (mana or life), unlike {G/W/P}
  it "plain phyrexian is not hybrid" do
    assert_search_results "is:hybrid mana>={w/p}"
    assert_search_results "is:hybrid mana>={c/p}"
  end
end

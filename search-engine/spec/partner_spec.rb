describe "partner queries" do
  include_context "db"

  it "is:partner" do
    assert_search_equal "is:partner -is:promo -e:plst,prm", %[
      ((o:"partner with") or
       (o:"partner" t:legendary t:creature) or
       (o:"partner" t:legendary t:planeswalker e:cmr) or
       (o:/^doctor.s companion/) or
       (o:/^precious/))
      -is:promo -e:plst,prm -(Playful Winners)
    ]
  end

  it "has:partner" do
    assert_search_equal "has:partner -e:prm", %[o:"partner with" -e:prm -(Knight of Land Drops)]
  end

  # Canary: every way of getting a second commander that isn't the Partner keyword
  # needs its own branch in PatchPartner, and its "Unknown partner text" guard only
  # fires on text that says "partner" - so a family like Ready to run, which doesn't,
  # goes unnoticed. A new one has to show up here, where it can be judged.
  it "no unrecognized second-commander wording" do
    assert_search_results %q[fo:/two commanders/ -is:partner -fo:/ready to run/]
    assert_search_results %q[fo:/second commander/ -is:partner -fo:/choose a background/]
  end
end

describe "mana cost queries" do
  include_context "db"

  it "no mana cost" do
    assert_search_equal "mana!={}", "mana>=0"
    assert_search_equal "mana=", "-mana>=0"
    assert_search_equal "-mana=", "mana>=0"
    assert_search_equal "mana={}", "mana="
    assert_search_equal "mana!={}", "mana!="
    assert_search_equal "mana={10}", "mana=10"
  end

  it "!=" do
    assert_search_equal "mana!=2r", "-mana=2r"
  end

  it "2/x" do
    assert_search_results "mana={2/r}{2/w}{2/b}",
      "Defibrillating Current",
      "Reigning Victor"
  end

  it "c/x" do
    assert_search_results "mana>={c/w}", "Ulalek, Fused Atrocity"
  end
end

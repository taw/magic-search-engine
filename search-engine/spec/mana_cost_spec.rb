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
end

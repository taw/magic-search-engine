describe "is:maindeck" do
  include_context "db"

  # Neither t:hero nor w:herospath quite match it
  # due to Fraction Jackson and Hall of Triumph respectively
  it "is:hero" do
    assert_search_equal "is:hero", "t:hero -(Fraction Jackson)"
    assert_search_equal "is:hero", "w:herospath -(Hall of Triumph)"
    assert_search_equal "is:hero", "e:thp1,thp2,thp3"
  end

  it "is:dungeon" do
    assert_search_equal "is:dungeon", "t:dungeon -(Dungeon Master)"
  end

  it "is:maindeck" do
    assert_search_equal "not:maindeck", "t:plane or t:phenomenon or t:vanguard or t:scheme or t:conspiracy or t:stickers or t:attraction or t:contraption or is:dungeon or is:hero"
    assert_search_equal "is:maindeck", "-(t:plane or t:phenomenon or t:vanguard or t:scheme or t:conspiracy or t:stickers or t:attraction or t:contraption or is:dungeon or is:hero)"
  end
end

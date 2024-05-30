describe "cast: spec" do
  include_context "db"

  it "is flexible in parsing" do
    assert_search_equal "cast=rw", "cast:rw"
    assert_search_equal "cast:rw", "cast:RW"
    assert_search_equal "cast:rw", "cast:{R}{w}"
  end

  it "ignores multiples mana" do
    assert_search_equal "cast:8wrrr", "cast:wr"
    assert_search_equal "cast:7", "cast:1"
  end

  it "lands cannot be cast" do
    assert_search_equal "cast:wubrg", "cast:wubrg -t:land"
    assert_search_results "cast:wubrg t:land"
  end

  it "count snow separately" do
    # assert_search_results "mana>={s} cast:wubrg"
    assert_search_equal "mana={s} cast:s", "mana={s}"
    assert_include_search "cast:sb", "cast:s"
    assert_include_search "cast:sb", "cast:b"
  end

  it "count colorless separately" do
    assert_search_results "mana>={c} cast:wubrg"
    # devoid MH3 cards with wild costs like 1GC mess this up
    # so we use ci=0 not c=0 to exclude them
    assert_search_equal "mana>={c} ci=0 cast:c", "mana>={c} ci=0"
  end

  it "treats Phyrexian as colorless" do
    assert_include_search "cast:1", "mana={pb}"
    assert_include_search "cast:b", "mana={pb}"
    assert_include_search "cast:r", "mana={pb}"
  end

  it "treats twobrid as colorless" do
    assert_include_search "cast:1", "mana={2w}{2w}{2w}"
    assert_include_search "cast:w", "mana={2w}{2w}{2w}"
    assert_include_search "cast:r", "mana={2w}{2w}{2w}"
  end

  it "hybrid" do
    assert_include_search "cast:w", "mana={wu}"
    assert_include_search "cast:u", "mana={wu}"
    assert_include_search "cast:wu", "mana={wu}"
  end
end

describe "in queries" do
  include_context "db"

  it "in:paper" do
    assert_search_equal "in:paper", "alt:game:paper"
  end

  it "in:mtgo" do
    assert_search_equal "in:mtgo", "alt:game:mtgo"
  end

  it "in:arena" do
    assert_search_equal "in:arena", "alt:game:arena"
  end

  it "in:shandalar" do
    assert_search_equal "in:shandalar", "alt:game:shandalar"
  end

  it "in:xmage" do
    assert_search_equal "in:xmage", "alt:game:xmage"
  end

  it "in:booster" do
    assert_search_equal "in:booster", "alt:is:booster"
  end

  it "in:foil" do
    assert_search_equal "in:foil", "alt:in:foil"
  end

  it "in:nonfoil" do
    assert_search_equal "in:nonfoil", "alt:in:nonfoil"
  end

  it "in:rarity" do
    assert_search_equal "in:basic", "alt:r:basic"
    assert_search_equal "in:common", "alt:r:common"
    assert_search_equal "in:uncommon", "alt:r:uncommon"
    assert_search_equal "in:rare", "alt:r:rare"
    assert_search_equal "in:mythic", "alt:r:mythic"
    assert_search_equal "in:special", "alt:r:special"
  end

  it "in: set type" do
    assert_search_equal "in:2hg", "alt:st:2hg"
    assert_search_equal "in:dd", "alt:st:dd"
    assert_search_equal "in:ex", "alt:st:ex"
    assert_search_equal "in:ftv", "alt:st:ftv"
    assert_search_equal "in:me", "alt:st:me"
    assert_search_equal "in:pc", "alt:st:pc"
    assert_search_equal "in:pds", "alt:st:pds"
    assert_search_equal "in:st", "alt:st:st"
    assert_search_equal "in:std", "alt:st:std"
    assert_search_equal "in:un", "alt:st:un"
    assert_search_equal %[in:"archenemy"], %[alt:st:"archenemy"]
    assert_search_equal %[in:"arena league"], %[alt:st:"arena league"]
    assert_search_equal %[in:"commander"], %[alt:st:"commander"]
    assert_search_equal %[in:"conspiracy"], %[alt:st:"conspiracy"]
    assert_search_equal %[in:"core"], %[alt:st:"core"]
    assert_search_equal %[in:"duel deck"], %[alt:st:"duel deck"]
    assert_search_equal %[in:"duels"], %[alt:st:"duels"]
    assert_search_equal %[in:"expansion"], %[alt:st:"expansion"]
    assert_search_equal %[in:"from the vault"], %[alt:st:"from the vault"]
    assert_search_equal %[in:"funny"], %[alt:st:"funny"]
    assert_search_equal %[in:"judge gift"], %[alt:st:"judge gift"]
    assert_search_equal %[in:"masterpiece"], %[alt:st:"masterpiece"]
    assert_search_equal %[in:"masters"], %[alt:st:"masters"]
    assert_search_equal %[in:"masters"], %[alt:st:"masters"]
    assert_search_equal %[in:"multiplayer"], %[alt:st:"multiplayer"]
    assert_search_equal %[in:"planechase"], %[alt:st:"planechase"]
    assert_search_equal %[in:"player rewards"], %[alt:st:"player rewards"]
    assert_search_equal %[in:"portal"], %[alt:st:"portal"]
    assert_search_equal %[in:"premiere shop"], %[alt:st:"premiere shop"]
    assert_search_equal %[in:"premium deck"], %[alt:st:"premium deck"]
    assert_search_equal %[in:"standard"], %[alt:st:"standard"]
    assert_search_equal %[in:"starter"], %[alt:st:"starter"]
    assert_search_equal %[in:"two-headed giant"], %[alt:st:"two-headed giant"]
    assert_search_equal %[in:"unset"], %[alt:st:"unset"]
  end

  it "in: set type spelling variants" do
    assert_search_equal %[in:"duel deck"], %[alt:st:DUEL_DECK]
  end

  # Should check all of them maybe?
  it "in: edition" do
    assert_search_equal "in:lea in:m10", "alt:e:lea alt:e:m10"
    assert_search_equal "in:zendikar in:commander", "alt:e:zendikar alt:st:commander"
    assert_search_equal "in:commander,m10,m11,m12", "alt:e:commander or alt:e:m10 or alt:e:m11 or alt:e:m12"

    db.sets.each do |set_code, set|
      # Skip sets with no cards just precons like Q07 and Q08
      next if set.printings.empty?
      assert_search_equal "in:#{set_code}", "alt:e:#{set_code}"
    end
  end
end

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
    assert_search_equal %Q[in:"archenemy"], %Q[alt:st:"archenemy"]
    assert_search_equal %Q[in:"arena league"], %Q[alt:st:"arena league"]
    assert_search_equal %Q[in:"commander"], %Q[alt:st:"commander"]
    assert_search_equal %Q[in:"conspiracy"], %Q[alt:st:"conspiracy"]
    assert_search_equal %Q[in:"core"], %Q[alt:st:"core"]
    assert_search_equal %Q[in:"duel deck"], %Q[alt:st:"duel deck"]
    assert_search_equal %Q[in:"duels"], %Q[alt:st:"duels"]
    assert_search_equal %Q[in:"expansion"], %Q[alt:st:"expansion"]
    assert_search_equal %Q[in:"from the vault"], %Q[alt:st:"from the vault"]
    assert_search_equal %Q[in:"funny"], %Q[alt:st:"funny"]
    assert_search_equal %Q[in:"gateway"], %Q[alt:st:"gateway"]
    assert_search_equal %Q[in:"judge gift"], %Q[alt:st:"judge gift"]
    assert_search_equal %Q[in:"masterpiece"], %Q[alt:st:"masterpiece"]
    assert_search_equal %Q[in:"masters"], %Q[alt:st:"masters"]
    assert_search_equal %Q[in:"masters"], %Q[alt:st:"masters"]
    assert_search_equal %Q[in:"multiplayer"], %Q[alt:st:"multiplayer"]
    assert_search_equal %Q[in:"planechase"], %Q[alt:st:"planechase"]
    assert_search_equal %Q[in:"player rewards"], %Q[alt:st:"player rewards"]
    assert_search_equal %Q[in:"portal"], %Q[alt:st:"portal"]
    assert_search_equal %Q[in:"premiere shop"], %Q[alt:st:"premiere shop"]
    assert_search_equal %Q[in:"premium deck"], %Q[alt:st:"premium deck"]
    assert_search_equal %Q[in:"standard"], %Q[alt:st:"standard"]
    assert_search_equal %Q[in:"starter"], %Q[alt:st:"starter"]
    assert_search_equal %Q[in:"two-headed giant"], %Q[alt:st:"two-headed giant"]
    assert_search_equal %Q[in:"unset"], %Q[alt:st:"unset"]
    assert_search_equal %Q[in:"wpn"], %Q[alt:st:"wpn"]
  end

  it "in: set type spelling variants" do
    assert_search_equal %Q[in:"duel deck"], %Q[alt:st:DUEL_DECK]
  end

  # Should check all of them maybe?
  it "in: edition" do
    assert_search_equal "in:lea in:m10", "alt:e:lea alt:e:m10"
    assert_search_equal "in:zendikar in:commander", "alt:e:zendikar alt:st:commander"
    assert_search_equal "in:commander,m10,m11,m12", "alt:e:commander or alt:e:m10 or alt:e:m11 or alt:e:m12"

    db.sets.each do |set_code, _|
      assert_search_equal "in:#{set_code}", "alt:e:#{set_code}"
    end
  end
end

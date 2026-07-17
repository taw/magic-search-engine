describe "Block search" do
  include_context "db"

  it "block codes" do
    assert_search_equal "b:rtr", 'b:"Return to Ravnica"'
    assert_search_equal "b:in", "b:Invasion"
    assert_search_equal "b:som", 'b:"Scars of Mirrodin"'
    assert_search_equal "b:som", "b:scars"
    assert_search_equal "b:mi", "b:Mirrodin"
  end

  it "block special characters" do
    assert_search_equal %[b:us], "b:urza"
    assert_search_equal %[b:"Urza's"], "b:urza"
  end

  it "block contents" do
    assert_search_equal "e:rtr OR e:gtc OR e:dgm", "b:rtr"
    assert_search_equal "e:in or e:ps or e:ap", "b:Invasion"
    assert_search_equal "e:isd or e:dka or e:avr", "b:Innistrad"
    assert_search_equal "e:lw or e:mt or e:shm or e:eve", "b:lorwyn"
    assert_search_equal "e:som or e:mbs or e:nph", "b:som"
    assert_search_equal "e:mi or e:ds or e:5dn", "b:mi"
    # Promos are now per set
    assert_search_equal "e:som or e:psom", "e:scars"
    assert_search_equal_cards 'f:"lorwyn shadowmoor block"', "b:lorwyn"
    # Fake blocks
    assert_search_equal "e:dom", "b:dom"
    # Gatherer codes
    assert_search_equal "b:lw", "b:lrw"
    assert_search_equal "b:mi", "b:mrd"
    assert_search_equal "b:mr", "b:mir"
    # Querying by second or third set code or name
    assert_search_equal "b:wwk", "b:zen"
    assert_search_equal "b:worldwake", "b:zen"
    assert_search_equal "b:unh", "b:un"
    assert_search_equal "b:unstable", "b:un"
  end

  it "comma separated block list" do
    assert_search_equal "b:isd or b:soi", "b:isd,soi"
  end

  it "unknown block warns" do
    db.search(%[b:nosuchblock]).warnings.should include(%[Unknown block "nosuchblock"])
    db.search("b:ravnica").warnings.should_not include(%[Unknown block "ravnica"])
  end
end

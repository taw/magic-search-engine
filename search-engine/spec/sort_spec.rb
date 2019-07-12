# Digital sets often have BS realese date
describe "Sorting" do
  include_context "db"

  it "name" do
    assert_search_results_ordered "t:chandra -is:digital sort:name",
      # Possibly we should skip commas while sorting ???
      "Chandra Ablaze",
      "Chandra Nalaar",
      "Chandra, Acolyte of Flame",
      "Chandra, Awakened Inferno",
      "Chandra, Bold Pyromancer",
      "Chandra, Fire Artisan",
      "Chandra, Flame's Fury",
      "Chandra, Flamecaller",
      "Chandra, Gremlin Wrangler",
      "Chandra, Novice Pyromancer",
      "Chandra, Pyrogenius",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Torch of Defiance",
      "Chandra, the Firebrand"
  end

  it "new" do
    assert_search_results_ordered "t:chandra -is:digital sort:new",
      "Chandra, Acolyte of Flame",
      "Chandra, Awakened Inferno",
      "Chandra, Flame's Fury",
      "Chandra, Novice Pyromancer",
      "Chandra, Fire Artisan",
      "Chandra, Bold Pyromancer",
      "Chandra, Pyrogenius",
      "Chandra, Torch of Defiance",
      "Chandra, Flamecaller",
      "Chandra, Roaring Flame",
      "Chandra, Pyromaster",
      "Chandra, the Firebrand",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, Gremlin Wrangler"
  end

  it "newall" do
    assert_search_results_ordered "t:chandra -is:digital sort:newall",
      "Chandra, Acolyte of Flame",
      "Chandra, Awakened Inferno",
      "Chandra, Flame's Fury",
      "Chandra, Novice Pyromancer",
      "Chandra, Fire Artisan",
      "Chandra, Torch of Defiance",
      "Chandra, Bold Pyromancer",
      "Chandra, Roaring Flame",
      "Chandra, Gremlin Wrangler",
      "Chandra, Pyromaster",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius",
      "Chandra Nalaar",
      "Chandra, the Firebrand",
      "Chandra Ablaze"
  end

  it "old" do
    assert_search_results_ordered "t:chandra -is:digital sort:old",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, the Firebrand",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius",
      "Chandra, Torch of Defiance",
      "Chandra, Bold Pyromancer",
      "Chandra, Fire Artisan",
      "Chandra, Acolyte of Flame",
      "Chandra, Awakened Inferno",
      "Chandra, Flame's Fury",
      "Chandra, Novice Pyromancer",
      "Chandra, Gremlin Wrangler"
  end

  it "oldall" do
    assert_search_results_ordered "t:chandra -is:digital sort:oldall",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, the Firebrand",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius",
      "Chandra, Torch of Defiance",
      "Chandra, Gremlin Wrangler",
      "Chandra, Bold Pyromancer",
      "Chandra, Fire Artisan",
      "Chandra, Acolyte of Flame",
      "Chandra, Awakened Inferno",
      "Chandra, Flame's Fury",
      "Chandra, Novice Pyromancer"

    end

  it "cmc" do
    assert_search_results_ordered "t:chandra -is:digital sort:cmc",
      "Chandra Ablaze",
      "Chandra, Awakened Inferno",
      "Chandra, Bold Pyromancer",
      "Chandra, Flame's Fury",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius",
      "Chandra Nalaar",
      "Chandra, Fire Artisan",
      "Chandra, Gremlin Wrangler",
      "Chandra, Novice Pyromancer",
      "Chandra, Pyromaster",
      "Chandra, Torch of Defiance",
      "Chandra, the Firebrand",
      "Chandra, Acolyte of Flame",
      "Chandra, Roaring Flame"
  end

  it "-cmc" do
    assert_search_results_ordered "t:chandra -is:digital sort:-cmc",
      "Chandra, Acolyte of Flame",
      "Chandra, Roaring Flame",
      "Chandra, Fire Artisan",
      "Chandra, Gremlin Wrangler",
      "Chandra, Novice Pyromancer",
      "Chandra, Pyromaster",
      "Chandra, Torch of Defiance",
      "Chandra, the Firebrand",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, Awakened Inferno",
      "Chandra, Bold Pyromancer",
      "Chandra, Flame's Fury",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius"
  end

  it "number" do
    assert_search_results_ordered "t:planeswalker e:m10 sort:number",
      "Ajani Goldmane",
      "Jace Beleren",
      "Liliana Vess",
      "Chandra Nalaar",
      "Garruk Wildspeaker"
  end

  it "-number" do
    assert_search_results_ordered "t:planeswalker e:m10 sort:-number",
      "Garruk Wildspeaker",
      "Chandra Nalaar",
      "Liliana Vess",
      "Jace Beleren",
      "Ajani Goldmane"
  end

  it "mixing orders" do
    assert_search_results_ordered "t:chandra -is:digital sort:cmc,-name",
      "Chandra, Pyrogenius",
      "Chandra, Flamecaller",
      "Chandra, Flame's Fury",
      "Chandra, Bold Pyromancer",
      "Chandra, Awakened Inferno",
      "Chandra Ablaze",
      "Chandra Nalaar",
      "Chandra, the Firebrand",
      "Chandra, Torch of Defiance",
      "Chandra, Pyromaster",
      "Chandra, Novice Pyromancer",
      "Chandra, Gremlin Wrangler",
      "Chandra, Fire Artisan",
      "Chandra, Roaring Flame",
      "Chandra, Acolyte of Flame"
  end

  it "random" do
    results1 = search("t:creature sort:rand")
    results2 = search("t:creature sort:name")
    results1.should_not eq(results2)
    results1.sort.should eq(results2.sort)
  end

  it "order: aliases sort:" do
    search("sort:cmc,-name").should eq search("order:cmc,-name")
  end

  let(:expected_color_order) {
    # Magic cards are ordered:
    # * monocolored (wubrg)
    # * multicolored
    # * colorless
    #
    # In most sets multicolored are grouped together.
    # Alara was ordered like below.
    # Wedges and 4/5-color order is completely arbitrary
    [
      "w", "u", "b", "r", "g",
      "wu", "ub", "br", "rg", "gw",
      "wb", "ur", "bg", "rw", "gu",
      "wub", "ubr", "brg", "rgw", "gwu",
      "wbr", "urg", "bgw", "rwu", "gub",
      "wubr", "ubrg", "brgw", "rgwu", "gwub",
      "wubrg",
      "",
    ].map{|cc| cc.chars.sort.join}
  }

  it "color" do
    order = db.search("sort:color").printings.map(&:colors).chunk(&:itself).map(&:first)
    order.should eq(expected_color_order)
  end

  it "ci" do
    order = db.search("sort:ci").printings.map(&:color_identity).chunk(&:itself).map(&:first)
    order.should eq(expected_color_order)
  end

  it "rarity" do
    order = db.search("sort:rarity").printings.map(&:rarity).chunk(&:itself).map(&:first)
    order.should eq(["special", "mythic", "rare", "uncommon", "common", "basic"])
  end
end

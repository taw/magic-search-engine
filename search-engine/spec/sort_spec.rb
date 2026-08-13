# Digital sets often have BS release date
describe "Sorting" do
  include_context "db"

  def ordered_search(query, *queries)
    results = Query.new(query).search(db).printings.uniq(&:card)
    queries = queries.map(&:to_proc)
    results.map{|c| queries.map{|q| q[c]}}
  end

  # Limiting the date etc. so this test doesn't need endless updating
  it "name" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:name", :name).should eq([
      ["Chandra Ablaze"],
      ["Chandra Nalaar"],
      ["Chandra, Acolyte of Flame"],
      ["Chandra, Awakened Inferno"],
      ["Chandra, Bold Pyromancer"],
      ["Chandra, Fire Artisan"],
      ["Chandra, Flame's Catalyst"],
      ["Chandra, Flame's Fury"],
      ["Chandra, Flamecaller"],
      ["Chandra, Heart of Fire"],
      ["Chandra, Novice Pyromancer"],
      ["Chandra, Pyrogenius"],
      ["Chandra, Pyromaster"],
      ["Chandra, Roaring Flame"],
      ["Chandra, Torch of Defiance"],
      ["Chandra, the Firebrand"],
    ])
  end

  it "artist" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:artist", :name, :artist_name).should eq([
      ["Chandra Nalaar", "Aleksi Briclot"],
      ["Chandra, Acolyte of Flame", "Anna Steinbauer"],
      ["Chandra, Novice Pyromancer", "Anna Steinbauer"],
      ["Chandra, Awakened Inferno", "Chris Rahn"],
      ["Chandra, Pyromaster", "Chris Rahn"],
      ["Chandra, the Firebrand", "D. Alexander Gregory"],
      ["Chandra, Roaring Flame", "Eric Deschamps"],
      ["Chandra, Flame's Catalyst", "Grzegorz Rutkowski"],
      ["Chandra, Flamecaller", "Jason Rainville"],
      ["Chandra, Heart of Fire", "Jason Rainville"],
      ["Chandra, Pyrogenius", "Jason Rainville"],
      ["Chandra, Flame's Fury", "Magali Villeneuve"],
      ["Chandra, Torch of Defiance", "Magali Villeneuve"],
      ["Chandra, Fire Artisan", "Ryota-H"],
      ["Chandra Ablaze", "Steve Argyle"],
      ["Chandra, Bold Pyromancer", "Zack Stella"],
    ])
  end

  it "new" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:new", :name, :set_code).should eq([
      ["Chandra, Flame's Catalyst", "m21"],
      ["Chandra, Heart of Fire", "m21"],
      ["Chandra, Acolyte of Flame", "m20"],
      ["Chandra, Awakened Inferno", "m20"],
      ["Chandra, Flame's Fury", "m20"],
      ["Chandra, Novice Pyromancer", "m20"],
      ["Chandra, Fire Artisan", "war"],
      ["Chandra, Bold Pyromancer", "dom"],
      ["Chandra, Pyrogenius", "kld"],
      ["Chandra, Torch of Defiance", "kld"],
      ["Chandra, Flamecaller", "ogw"],
      ["Chandra, Roaring Flame", "ori"],
      ["Chandra, Pyromaster", "m15"],
      ["Chandra, the Firebrand", "m13"],
      ["Chandra Nalaar", "m11"],
      ["Chandra Ablaze", "zen"],
    ])
  end

  it "newall" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:newall", :name, :set_code).should eq([
      ["Chandra, Torch of Defiance", "q06"],
      ["Chandra, Flame's Catalyst", "m21"],
      ["Chandra, Heart of Fire", "m21"],
      ["Chandra, Flamecaller", "c20"],
      ["Chandra, Acolyte of Flame", "m20"],
      ["Chandra, Awakened Inferno", "m20"],
      ["Chandra, Flame's Fury", "m20"],
      ["Chandra, Novice Pyromancer", "m20"],
      ["Chandra, Fire Artisan", "war"],
      ["Chandra, Bold Pyromancer", "dom"],
      ["Chandra, Roaring Flame", "v17"],
      ["Chandra, Pyromaster", "e01"],
      ["Chandra, Pyrogenius", "kld"],
      ["Chandra Nalaar", "jvc"],
      ["Chandra, the Firebrand", "m13"],
      ["Chandra Ablaze", "zen"],
    ])
  end

  it "released" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:newall", :name, :set_code).should eq(
      ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:released", :name, :set_code))
  end

  it "old" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:old", :name, :set_code).should eq([
      ["Chandra Nalaar", "lrw"],
      ["Chandra Ablaze", "zen"],
      ["Chandra, the Firebrand", "m12"],
      ["Chandra, Pyromaster", "m14"],
      ["Chandra, Roaring Flame", "ori"],
      ["Chandra, Flamecaller", "ogw"],
      ["Chandra, Pyrogenius", "kld"],
      ["Chandra, Torch of Defiance", "kld"],
      ["Chandra, Bold Pyromancer", "dom"],
      ["Chandra, Fire Artisan", "war"],
      ["Chandra, Acolyte of Flame", "m20"],
      ["Chandra, Awakened Inferno", "m20"],
      ["Chandra, Flame's Fury", "m20"],
      ["Chandra, Novice Pyromancer", "m20"],
      ["Chandra, Flame's Catalyst", "m21"],
      ["Chandra, Heart of Fire", "m21"],
    ])
  end

  it "oldall" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:oldall", :name, :set_code).should eq([
      ["Chandra Nalaar", "lrw"],
      ["Chandra Ablaze", "zen"],
      ["Chandra, the Firebrand", "m12"],
      ["Chandra, Pyromaster", "m14"],
      ["Chandra, Roaring Flame", "ori"],
      ["Chandra, Flamecaller", "ogw"],
      ["Chandra, Pyrogenius", "kld"],
      ["Chandra, Torch of Defiance", "kld"],
      ["Chandra, Bold Pyromancer", "dom"],
      ["Chandra, Fire Artisan", "war"],
      ["Chandra, Acolyte of Flame", "m20"],
      ["Chandra, Awakened Inferno", "m20"],
      ["Chandra, Flame's Fury", "m20"],
      ["Chandra, Novice Pyromancer", "m20"],
      ["Chandra, Flame's Catalyst", "m21"],
      ["Chandra, Heart of Fire", "m21"],
    ])
  end

  it "cmc" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:cmc", :name, :mv).should eq([
      ["Chandra Ablaze", 6],
      ["Chandra, Awakened Inferno", 6],
      ["Chandra, Bold Pyromancer", 6],
      ["Chandra, Flame's Catalyst", 6],
      ["Chandra, Flame's Fury", 6],
      ["Chandra, Flamecaller", 6],
      ["Chandra, Pyrogenius", 6],
      ["Chandra Nalaar", 5],
      ["Chandra, Heart of Fire", 5],
      ["Chandra, Fire Artisan", 4],
      ["Chandra, Novice Pyromancer", 4],
      ["Chandra, Pyromaster", 4],
      ["Chandra, Torch of Defiance", 4],
      ["Chandra, the Firebrand", 4],
      ["Chandra, Acolyte of Flame", 3],
      ["Chandra, Roaring Flame", 3],
    ])
  end

  it "-cmc" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:-cmc", :name, :mv).should eq([
      ["Chandra, Acolyte of Flame", 3],
      ["Chandra, Roaring Flame", 3],
      ["Chandra, Fire Artisan", 4],
      ["Chandra, Novice Pyromancer", 4],
      ["Chandra, Pyromaster", 4],
      ["Chandra, Torch of Defiance", 4],
      ["Chandra, the Firebrand", 4],
      ["Chandra Nalaar", 5],
      ["Chandra, Heart of Fire", 5],
      ["Chandra Ablaze", 6],
      ["Chandra, Awakened Inferno", 6],
      ["Chandra, Bold Pyromancer", 6],
      ["Chandra, Flame's Catalyst", 6],
      ["Chandra, Flame's Fury", 6],
      ["Chandra, Flamecaller", 6],
      ["Chandra, Pyrogenius", 6],
    ])
  end

  it "mv" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:mv", :name, :mv).should eq([
      ["Chandra Ablaze", 6],
      ["Chandra, Awakened Inferno", 6],
      ["Chandra, Bold Pyromancer", 6],
      ["Chandra, Flame's Catalyst", 6],
      ["Chandra, Flame's Fury", 6],
      ["Chandra, Flamecaller", 6],
      ["Chandra, Pyrogenius", 6],
      ["Chandra Nalaar", 5],
      ["Chandra, Heart of Fire", 5],
      ["Chandra, Fire Artisan", 4],
      ["Chandra, Novice Pyromancer", 4],
      ["Chandra, Pyromaster", 4],
      ["Chandra, Torch of Defiance", 4],
      ["Chandra, the Firebrand", 4],
      ["Chandra, Acolyte of Flame", 3],
      ["Chandra, Roaring Flame", 3],
    ])
  end

  it "-mv" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:-mv", :name, :mv).should eq([
      ["Chandra, Acolyte of Flame", 3],
      ["Chandra, Roaring Flame", 3],
      ["Chandra, Fire Artisan", 4],
      ["Chandra, Novice Pyromancer", 4],
      ["Chandra, Pyromaster", 4],
      ["Chandra, Torch of Defiance", 4],
      ["Chandra, the Firebrand", 4],
      ["Chandra Nalaar", 5],
      ["Chandra, Heart of Fire", 5],
      ["Chandra Ablaze", 6],
      ["Chandra, Awakened Inferno", 6],
      ["Chandra, Bold Pyromancer", 6],
      ["Chandra, Flame's Catalyst", 6],
      ["Chandra, Flame's Fury", 6],
      ["Chandra, Flamecaller", 6],
      ["Chandra, Pyrogenius", 6],
    ])
  end

  # sort:set is by set name, not set code
  it "set" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:set", :name, :set_name, :set_code, :number).should eq([
      ["Chandra, Pyromaster", "Archenemy: Nicol Bolas", "e01", "42"],
      ["Chandra, Flamecaller", "Commander 2020", "c20", "145"],
      ["Chandra, Acolyte of Flame", "Core Set 2020", "m20", "126"],
      ["Chandra, Awakened Inferno", "Core Set 2020", "m20", "127"],
      ["Chandra, Flame's Fury", "Core Set 2020", "m20", "294"],
      ["Chandra, Novice Pyromancer", "Core Set 2020", "m20", "128"],
      ["Chandra, Flame's Catalyst", "Core Set 2021", "m21", "332"],
      ["Chandra, Heart of Fire", "Core Set 2021", "m21", "135"],
      ["Chandra, Bold Pyromancer", "Dominaria", "dom", "275"],
      ["Chandra Nalaar", "Duel Decks Anthology: Jace vs. Chandra", "jvc", "34"],
      ["Chandra, Roaring Flame", "From the Vault: Transform", "v17", "6b"],
      ["Chandra, Pyrogenius", "Kaladesh", "kld", "265"],
      ["Chandra, Torch of Defiance", "Kaladesh", "kld", "110"],
      ["Chandra, the Firebrand", "Magic 2012", "m12", "124"],
      ["Chandra, Fire Artisan", "War of the Spark", "war", "119"],
      ["Chandra Ablaze", "Zendikar", "zen", "120"],
    ])
  end

  # Only set order is reversed, printings within a set keep default order
  it "-set" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:-set", :name, :set_name, :set_code, :number).should eq([
      ["Chandra Ablaze", "Zendikar", "zen", "120"],
      ["Chandra, Fire Artisan", "War of the Spark", "war", "119"],
      ["Chandra, Torch of Defiance", "Signature Spellbook: Chandra", "ss3", "1"],
      ["Chandra, Flamecaller", "Oath of the Gatewatch", "ogw", "104"],
      ["Chandra, Roaring Flame", "Magic Origins", "ori", "135b"],
      ["Chandra, Pyromaster", "Magic 2015", "m15", "134"],
      ["Chandra, the Firebrand", "Magic 2013", "m13", "123"],
      ["Chandra Nalaar", "Magic 2011", "m11", "127"],
      ["Chandra, Pyrogenius", "Kaladesh", "kld", "265"],
      ["Chandra, Bold Pyromancer", "Dominaria", "dom", "275"],
      ["Chandra, Flame's Catalyst", "Core Set 2021", "m21", "332"],
      ["Chandra, Heart of Fire", "Core Set 2021", "m21", "135"],
      ["Chandra, Acolyte of Flame", "Core Set 2020", "m20", "126"],
      ["Chandra, Awakened Inferno", "Core Set 2020", "m20", "127"],
      ["Chandra, Flame's Fury", "Core Set 2020", "m20", "294"],
      ["Chandra, Novice Pyromancer", "Core Set 2020", "m20", "128"],
    ])
  end

  it "number" do
    ordered_search("t:planeswalker e:m10,m12 sort:number", :name, :set_code, :number).should eq([
      ["Ajani Goldmane", "m10", "1"],
      ["Jace Beleren", "m10", "58"],
      ["Liliana Vess", "m10", "102"],
      ["Chandra Nalaar", "m10", "132"],
      ["Garruk Wildspeaker", "m10", "183"],
      ["Gideon Jura", "m12", "16"],
      ["Jace, Memory Adept", "m12", "58"],
      ["Sorin Markov", "m12", "109"],
      ["Chandra, the Firebrand", "m12", "124"],
      ["Garruk, Primal Hunter", "m12", "174"],
    ])
  end

  it "-number" do
    ordered_search("t:planeswalker e:m10,m12 sort:-number", :name, :set_code, :number).should eq([
      ["Garruk, Primal Hunter", "m12", "174"],
      ["Chandra, the Firebrand", "m12", "124"],
      ["Sorin Markov", "m12", "109"],
      ["Jace, Memory Adept", "m12", "58"],
      ["Gideon Jura", "m12", "16"],
      ["Garruk Wildspeaker", "m10", "183"],
      ["Chandra Nalaar", "m10", "132"],
      ["Liliana Vess", "m10", "102"],
      ["Jace Beleren", "m10", "58"],
      ["Ajani Goldmane", "m10", "1"],
    ])
  end

  it "mixing orders" do
    ordered_search("t:chandra -is:digital -is:promo -e:sld time=2021-11-01 sort:cmc,-name", :name, :mv).should eq([
      ["Chandra, Pyrogenius", 6],
      ["Chandra, Flamecaller", 6],
      ["Chandra, Flame's Fury", 6],
      ["Chandra, Flame's Catalyst", 6],
      ["Chandra, Bold Pyromancer", 6],
      ["Chandra, Awakened Inferno", 6],
      ["Chandra Ablaze", 6],
      ["Chandra, Heart of Fire", 5],
      ["Chandra Nalaar", 5],
      ["Chandra, the Firebrand", 4],
      ["Chandra, Torch of Defiance", 4],
      ["Chandra, Pyromaster", 4],
      ["Chandra, Novice Pyromancer", 4],
      ["Chandra, Fire Artisan", 4],
      ["Chandra, Roaring Flame", 3],
      ["Chandra, Acolyte of Flame", 3],
    ])
  end

  # What sort:set is for - narrow with an e: list, then order within each set
  it "sort:set with a secondary order" do
    ordered_search("t:goblin e:m10,m12 sort:set,rarity", :name, :set_name, :rarity).should eq([
      ["Goblin Chieftain", "Magic 2010", "rare"],
      ["Siege-Gang Commander", "Magic 2010", "rare"],
      ["Goblin Artillery", "Magic 2010", "uncommon"],
      ["Goblin Piker", "Magic 2010", "common"],
      ["Raging Goblin", "Magic 2010", "common"],
      ["Goblin Bangchuckers", "Magic 2012", "uncommon"],
      ["Goblin Arsonist", "Magic 2012", "common"],
      ["Goblin Fireslinger", "Magic 2012", "common"],
      ["Goblin Tunneler", "Magic 2012", "common"],
    ])
  end

  it "sort:pow" do
    ordered_search("e:kld r:mythic t:artifact sort:pow", :name, :power, proc{|c| c.types.include?("vehicle")}).should eq([
      ["Combustible Gearhulk", 6, false],
      ["Skysovereign, Consul Flagship", 6, true],
      ["Noxious Gearhulk", 5, false],
      ["Torrential Gearhulk", 5, false],
      ["Cataclysmic Gearhulk", 4, false],
      ["Verdurous Gearhulk", 4, false],
      ["Aetherworks Marvel", nil, false],
    ])
  end

  it "sort:power" do
    ordered_search("e:kld r:mythic t:artifact sort:power", :name, :power, proc{|c| c.types.include?("vehicle")}).should eq([
      ["Combustible Gearhulk", 6, false],
      ["Skysovereign, Consul Flagship", 6, true],
      ["Noxious Gearhulk", 5, false],
      ["Torrential Gearhulk", 5, false],
      ["Cataclysmic Gearhulk", 4, false],
      ["Verdurous Gearhulk", 4, false],
      ["Aetherworks Marvel", nil, false],
    ])
  end

  it "sort:tou" do
    ordered_search("e:kld r:mythic t:artifact sort:tou", :name, :toughness, proc{|c| c.types.include?("vehicle")}).should eq([
      ["Combustible Gearhulk", 6, false],
      ["Torrential Gearhulk", 6, false],
      ["Cataclysmic Gearhulk", 5, false],
      ["Skysovereign, Consul Flagship", 5, true],
      ["Noxious Gearhulk", 4, false],
      ["Verdurous Gearhulk", 4, false],
      ["Aetherworks Marvel", nil, false],
    ])
  end

  it "sort:toughness" do
    ordered_search("e:kld r:mythic t:artifact sort:toughness", :name, :toughness, proc{|c| c.types.include?("vehicle")}).should eq([
      ["Combustible Gearhulk", 6, false],
      ["Torrential Gearhulk", 6, false],
      ["Cataclysmic Gearhulk", 5, false],
      ["Skysovereign, Consul Flagship", 5, true],
      ["Noxious Gearhulk", 4, false],
      ["Verdurous Gearhulk", 4, false],
      ["Aetherworks Marvel", nil, false],
    ])
  end

  it "sort:firstprint" do
    ordered_search("c=c o:regenerate sort:firstprint", :name)[0,3].should eq([
      ["Accursed Duneyard"],
      ["Birthing Hulk"],
      ["Unnatural Endurance"],
    ])
  end

  # test shouldn't need updates as they won't be reprinting those (even is:reserved gets MTGO promos)
  it "sort:lastprint" do
    ordered_search("is:racist sort:lastprint", :name).should eq([
      ["Crusade"],
      ["Cleanse"],
      ["Pradesh Gypsies"],
      ["Imprison"],
      ["Invoke Prejudice"],
      ["Jihad"],
      ["Stone-Throwing Devils"],
    ])
  end

  it "sort:rand" do
    results1 = search("t:creature sort:rand")
    results2 = search("t:creature sort:name")
    results1.should_not eq(results2)
    results1.sort.should eq(results2.sort)
  end

  it "sort:random" do
    results1 = search("t:creature sort:random")
    results2 = search("t:creature sort:name")
    results1.should_not eq(results2)
    results1.sort.should eq(results2.sort)
  end

  it "order: aliases sort:" do
    search("sort:cmc,-name").should eq search("order:cmc,-name")
  end

  let(:expected_color_order) {
    # Magic cards are ordered:
    # * colorless
    # * monocolored (wubrg)
    # * multicolored
    #
    # In most sets multicolored are grouped together.
    # Alara was ordered like below.
    # Wedges and 4/5-color order is completely arbitrary
    [
      "",
      "w", "u", "b", "r", "g",
      "wu", "ub", "br", "rg", "gw",
      "wb", "ur", "bg", "rw", "gu",
      "gwu", "wub", "ubr", "brg", "rgw",
      "bgw", "rwu", "gub", "wbr", "urg",
      "wubr", "ubrg", "brgw", "rgwu", "gwub",
      "wubrg",
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

  # Sorter throws away everything after a FINAL_SORT_ORDERS key, which is only
  # allowed while those keys really do order every printing by themselves
  describe "redundant sort keys" do
    it "final sort orders are unique per printing" do
      Sorter::FINAL_SORT_ORDERS.each do |part|
        sorter = Sorter.new(part, "seed")
        keys = db.printings.map{|c| sorter.send(:card_key, c)}
        keys.uniq.size.should eq(db.printings.size), "#{part} does not order every printing"
      end
    end

    it "ignores a repeated sort key" do
      db.search("sort:name,name").printings.should eq(db.search("sort:name").printings)
      db.search("sort:mv,rarity,mv").printings.should eq(db.search("sort:mv,rarity").printings)
    end

    it "ignores sort keys after a final one" do
      db.search("sort:default,name,rarity").printings.should eq(db.search("sort:default").printings)
      db.search("sort:number,rarity,newall").printings.should eq(db.search("sort:number").printings)
      db.search("sort:name,number,artist").printings.should eq(db.search("sort:name,number").printings)
    end

    # random is per card name, not per printing, so it is not a final key
    it "keeps sort keys after random" do
      Query.new("sort:random,rarity", "seed").search(db).printings
        .should_not eq(Query.new("sort:random", "seed").search(db).printings)
    end
  end

  # sort:pow / sort:tou / sort:mv map their values onto small integers, so the
  # sort key can eventually be one number instead of an array. The mapping
  # raises on any special value it hasn't been taught, and it only keeps the
  # right order while the data stays inside the range it assumes, so check the
  # whole database against it rather than waiting for a mis-sorted card.
  describe "power/toughness/mv sort keys" do
    let(:sorter) { Sorter.new(nil, "") }
    let(:power_toughness) { db.cards.each_value.flat_map{|c| [c.power, c.toughness]}.uniq }
    let(:numbers) { power_toughness.grep(Numeric).sort }
    let(:specials) { power_toughness - numbers }
    let(:mvs) { db.cards.each_value.map(&:mv).uniq }

    def map_pt(value)
      sorter.send(:map_pt, value)
    end

    def map_mv(value)
      sorter.send(:map_mv, value)
    end

    it "knows every special power/toughness in the database" do
      (specials - Sorter::PT_ORDER.keys).should eq([])
    end

    it "has no power/toughness fraction except halves" do
      numbers.reject{|v| v * 2 == (v * 2).to_i}.should eq([])
    end

    it "has an mv for every card" do
      mvs.should_not include(nil)
    end

    it "has no mv fraction except halves" do
      mvs.reject{|v| v * 2 == (v * 2).to_i}.should eq([])
    end

    # Numbers map to 10 + 2 * value, so they clear the specials while they stay
    # above -2.5, and stay under ∞ while they stay below 495
    it "orders every power/toughness number above the special values" do
      highest_special = Sorter::PT_ORDER.reject{|value, _| value == "∞"}.values.max
      numbers.select{|v| map_pt(v) <= highest_special}.should eq([])
    end

    it "orders every power/toughness number below ∞" do
      numbers.select{|v| map_pt(v) >= Sorter::PT_ORDER.fetch("∞")}.should eq([])
    end

    it "maps power/toughness numbers in ascending order" do
      numbers.each_cons(2).reject{|a, b| map_pt(a) < map_pt(b)}.should eq([])
    end

    # Everything above 1000 collapses onto one key, which only orders correctly
    # while Gleemax is the single card up there
    it "maps mv in ascending order, including the values it clamps" do
      mvs.sort.each_cons(2).reject{|a, b| map_mv(a) < map_mv(b)}.should eq([])
    end

    it "sorts half power between the numbers around it" do
      ordered_search("e:unh t:creature pow<=1 sort:-pow", :name, :power).should eq([
        ["Emcee", 0],
        ["Pygmy Giant", 0],
        ["Six-y Beast", 0],
        ["Little Girl", 0.5],
        ["Artful Looter", 1],
        ["B-I-N-G-O", 1],
        ["Bosom Buddy", 1],
        ["Cheap Ass", 1],
        ["Fraction Jackson", 1],
        ["Johnny, Combo Player", 1],
        ["Magical Hacker", 1],
        ["Monkey Monkey Monkey", 1],
        ["Mons's Goblin Waiters", 1],
        ["Tainted Monkey", 1],
        ["Zombie Fanboy", 1],
        ["_____", 1],
      ])
    end

    it "sorts half mv between the numbers around it" do
      ordered_search("e:unh mv<=1 (t:creature or t:land) sort:-mv", :name, :mv).should eq([
        ["City of Ass", 0],
        ["Forest", 0],
        ["Island", 0],
        ["Mountain", 0],
        ["Plains", 0],
        ["R&D's Secret Lair", 0],
        ["Swamp", 0],
        ["Little Girl", 0.5],
        ["Mons's Goblin Waiters", 1],
        ["S.N.O.T.", 1],
      ])
    end

    it "sorts special power below every number" do
      ordered_search("e:unh t:creature (pow=* or pow=*² or pow=0) sort:-pow", :name, :power).should eq([
        ["Avatar of Me", "*"],
        ["Elvish House Party", "*"],
        ["S.N.O.T.", "*²"],
        ["Emcee", 0],
        ["Pygmy Giant", 0],
        ["Six-y Beast", 0],
      ])
    end

    it "sorts ∞ above every number" do
      ordered_search("e:ulst t:creature pow>=9 sort:pow", :name, :power).should eq([
        ["Infinity Elemental", "∞"],
        ["Infernius Spawnington III, Esq.", 9],
      ])
    end
  end
end

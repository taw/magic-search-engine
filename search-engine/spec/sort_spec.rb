describe "Sorting" do
  include_context "db"

  it "name" do
    assert_search_results_ordered "t:chandra sort:name",
      "Chandra Ablaze",
      "Chandra Nalaar",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Torch of Defiance",
      "Chandra, the Firebrand"
  end

  it "new" do
    assert_search_results_ordered "t:chandra sort:new",
      "Chandra, Pyrogenius",
      "Chandra, Torch of Defiance",
      "Chandra, Flamecaller",
      "Chandra, Roaring Flame",
      "Chandra, Pyromaster",
      "Chandra, the Firebrand",
      "Chandra Nalaar",
      "Chandra Ablaze"
  end

  it "newall" do
    # Jace v Chandra printing of Chandra Nalaar changes order
    assert_search_results_ordered "t:chandra sort:newall",
      "Chandra, Pyromaster",
      "Chandra, Pyrogenius",
      "Chandra, Torch of Defiance",
      "Chandra, Flamecaller",
      "Chandra, Roaring Flame",
      "Chandra Nalaar",
      "Chandra, the Firebrand",
      "Chandra Ablaze"
  end

  it "old" do
    assert_search_results_ordered "t:chandra sort:old",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, the Firebrand",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius",
      "Chandra, Torch of Defiance"
  end

  it "oldall" do
    assert_search_results_ordered "t:chandra sort:oldall",
      "Chandra Nalaar",
      "Chandra Ablaze",
      "Chandra, the Firebrand",
      "Chandra, Pyromaster",
      "Chandra, Roaring Flame",
      "Chandra, Flamecaller",
      "Chandra, Pyrogenius",
      "Chandra, Torch of Defiance"
  end

  it "cmc" do
    assert_search_results_ordered "t:chandra sort:cmc",
      "Chandra Ablaze",             # 6
      "Chandra, Flamecaller",       # 6
      "Chandra, Pyrogenius",        # 6
      "Chandra Nalaar",             # 5
      "Chandra, Pyromaster",        # 4
      "Chandra, Torch of Defiance", # 4
      "Chandra, the Firebrand",     # 4
      "Chandra, Roaring Flame"      # 3
  end

  it "cmc" do
    assert_search_results_ordered "t:planeswalker e:m10 sort:number",
      "Ajani Goldmane",
      "Jace Beleren",
      "Liliana Vess",
      "Chandra Nalaar",
      "Garruk Wildspeaker"
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
end

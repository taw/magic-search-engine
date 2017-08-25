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
end

describe "new: queries" do
  include_context "db", "lea", "2ed", "5ed", "por", "6ed", "7ed", "8ed", "ps11", "akh", "gs1", "m19", "sta"

  # Giant Spider was always a common, but changed just about everything else
  # over the years, so it covers most properties on its own.
  let(:spider) { %Q[++ n:"Giant Spider"] }

  it "new:artist" do
    # Both 7ed printings count, as they came out the same day
    search("#{spider} new:artist").should match_array([
      "Giant Spider [lea/198]",
      "Giant Spider [5ed/300]",
      "Giant Spider [por/167]",
      "Giant Spider [7ed/249]",
      "Giant Spider [7ed/249★]",
      "Giant Spider [akh/166]",
      "Giant Spider [gs1/27]",
    ])
  end

  it "new:rarity" do
    search("#{spider} new:rarity").should match_array([
      "Giant Spider [lea/198]",
    ])
  end

  it "new:border" do
    search("#{spider} new:border").should match_array([
      "Giant Spider [lea/198]",
      "Giant Spider [2ed/199]",
    ])
  end

  it "new:frame" do
    search("#{spider} new:frame").should match_array([
      "Giant Spider [lea/198]",
      "Giant Spider [5ed/300]",
      "Giant Spider [8ed/255]",
      "Giant Spider [8ed/255★]",
      "Giant Spider [akh/166]",
    ])
  end

  it "new:flavor" do
    search("#{spider} new:flavor").should match_array([
      "Giant Spider [lea/198]",
      "Giant Spider [5ed/300]",
      "Giant Spider [por/167]",
      "Giant Spider [7ed/249]",
      "Giant Spider [7ed/249★]",
      "Giant Spider [akh/166]",
      "Giant Spider [gs1/27]",
      "Giant Spider [m19/183]",
    ])
  end

  it "new:foil" do
    search("#{spider} new:foil").should match_array([
      "Giant Spider [7ed/249★]",
    ])
  end

  it "new:nonfoil" do
    search("#{spider} new:nonfoil").should match_array([
      "Giant Spider [lea/198]",
    ])
  end

  it "new:game" do
    search("#{spider} new:game").should match_array([
      "Giant Spider [lea/198]",  # paper, shandalar, xmage
      "Giant Spider [6ed/234]",  # dreamcast
      "Giant Spider [7ed/249]",  # mtgo
      "Giant Spider [7ed/249★]", # mtgo
      "Giant Spider [m19/183]",  # arena
    ])
  end

  it "new:watermark" do
    search("#{spider} new:watermark").should match_array([
      "Giant Spider [7ed/249★]",
    ])
  end

  it "new:frameeffect" do
    search(%Q[++ n:"Lightning Bolt" new:frameeffect]).should match_array([
      "Lightning Bolt [sta/42]",
    ])
  end

  it "printings without the property are never new" do
    search("++ new:flavor -has:flavor").should eq([])
    search("++ new:watermark -has:watermark").should eq([])
    search("++ new:foil -is:foil").should eq([])
    search("++ new:nonfoil -is:nonfoil").should eq([])
    search_printings("++ new:frameeffect").should be_all{|c| !c.frame_effects.empty? }
    search_printings("++ new:game").should be_all{|c| !c.games.empty? }
  end

  it "aliases" do
    "#{spider} new:illustrator".should equal_search "#{spider} new:artist"
    "#{spider} new:flavour".should equal_search "#{spider} new:flavor"
    "#{spider} new:flavortext".should equal_search "#{spider} new:flavor"
    "#{spider} new:ft".should equal_search "#{spider} new:flavor"
    "#{spider} new:wm".should equal_search "#{spider} new:watermark"
    %Q[++ n:"Lightning Bolt" new:frameeffects].should equal_search %Q[++ n:"Lightning Bolt" new:frameeffect]
  end

  it "unknown properties warn instead of matching everything" do
    query = Query.new("new:banana")
    query.warnings.should eq([
      "Unknown new: banana. Known options are: artist, border, flavor, foil, frame, frameeffect, game, nonfoil, rarity, watermark.",
    ])
  end

  it "query_to_s" do
    ConditionNew::PROPERTIES.each do |property|
      Query.new("new:#{property}").to_s.should eq("new:#{property}")
    end
  end
end

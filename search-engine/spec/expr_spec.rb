describe "Expressions Test" do
  include_context "db"

  it "warns about values it cannot parse" do
    db.search("pow>=1.2.3").warnings.should include(%[Unknown value "1.2.3" in "pow>=1.2.3"])
    db.search("cmc>=2+2").warnings.should include(%[Unknown value "2+2" in "cmc>=2+2"])
    db.search("pow>=xx").warnings.should include(%[Unknown value "xx" in "pow>=xx"])
    # Values which are perfectly fine, just no card matches them
    db.search("pow>=1d4+1").warnings.should be_empty
    db.search("pow>=∞").warnings.should be_empty
    db.search("pow>=*2").warnings.should be_empty
    db.search("tou<=1½").warnings.should be_empty
    db.search("cmc>=2 pow>tou loy>=5 year>=2000 decklimit>=4").warnings.should be_empty
  end

  it "year" do
    "t:planeswalker year = 2010".should have_count_printings 16
    "t:planeswalker year < 2013".should have_count_printings 72
    "t:planeswalker year > 2014".should equal_search "t:planeswalker year >= 2015"
  end

  it "sets" do
    assert_search_equal "sets=1 or sets=2 or sets=3", "sets<=3"
    assert_search_equal "sets=1 or sets=2 or sets=3", "sets<4"
    assert_search_equal "sets>7", "sets>=8"
  end

  it "prints" do
    assert_search_equal "prints=1 or prints=2 or prints=3", "prints<=3"
    assert_search_equal "prints=1 or prints=2 or prints=3", "prints<4"
    assert_search_equal "prints>7", "prints>=8"
  end

  it "papersets" do
    assert_search_equal "papersets=0 or papersets=1 or papersets=2 or papersets=3", "papersets<=3"
    assert_search_equal "papersets=0 or papersets=1 or papersets=2 or papersets=3", "papersets<4"
    assert_search_equal "papersets>7", "papersets>=8"
  end

  it "paperprints" do
    assert_search_equal "paperprints=0 or paperprints=1 or paperprints=2 or paperprints=3", "paperprints<=3"
    assert_search_equal "paperprints=0 or paperprints=1 or paperprints=2 or paperprints=3", "paperprints<4"
    assert_search_equal "paperprints>7", "paperprints>=8"
  end

  it "prints and sets expressions" do
    card = db.cards["giant spider"]
    assert_search_include "prints=#{card.printings.size}", "Giant Spider"
    assert_search_include "paperprints=#{card.printings.count(&:paper?)}", "Giant Spider"
    assert_search_include "sets=#{card.printings.map(&:set).uniq.size}", "Giant Spider"
    assert_search_include "papersets=#{card.printings.select(&:paper?).map(&:set).uniq.size}", "Giant Spider"
  end

  it "defense" do
    assert_search_results "defense=7 e:mom",
      "Invasion of Alara",
      "Invasion of Arcavios"
    assert_search_results "defense<4 e:mom",
      "Invasion of Gobakhan",
      "Invasion of Zendikar"
    assert_search_equal "defense=7", "defence=7"
  end

  it "hand" do
    assert_search_results "hand=-3",
      "Multani"
    assert_search_equal "hand=+1", "hand=1"
  end

  it "life" do
    assert_search_results "life<-6",
      "Ashnod",
      "Takara",
      "Maro Avatar" # Magic Online Avatars
    assert_search_equal "life=+1", "life=1"
    assert_search_equal "life=+0", "life=0"
    assert_search_equal "life=-0", "life=0"
  end
end

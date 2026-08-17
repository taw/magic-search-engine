# Packs the sealed simulator asks for by code, straight out of a url,
# so anything goes
describe "CardDatabase#boosters_for_descriptor" do
  include_context "db"

  def codes(descriptor)
    db.boosters_for_descriptor(descriptor).map(&:code)
  end

  it "finds a booster by its code" do
    codes("nph-draft").should eq ["nph-draft"]
  end

  # "Explore this pack in Sealed" on /pack/nph links here by set code
  it "finds a set's default booster by set code alone" do
    codes("nph").should eq ["nph-draft"]
  end

  # The allied guild booster of the Dragon's Maze prerelease could have been
  # any of four packs, and we roll it every time the pool is opened
  it "finds every alternative of a pack picked at random" do
    codes("gtc-prerelease-orzhov|gtc-prerelease-dimir").should eq(
      ["gtc-prerelease-orzhov", "gtc-prerelease-dimir"]
    )
  end

  it "has no booster for a set we don't know" do
    codes("lolwtf").should eq []
  end

  it "has no booster for a variant we don't know" do
    codes("nph-lolwtf").should eq []
  end

  it "has no booster for a set which has none" do
    codes("c15").should eq []
  end

  it "skips the alternatives it doesn't have" do
    codes("lolwtf|nph-draft").should eq ["nph-draft"]
  end

  it "has no booster for nothing at all" do
    codes(nil).should eq []
    codes("").should eq []
  end

  it "finds every booster we support by its own code" do
    db.unique_supported_booster_types.each do |code, booster|
      codes(code).should eq [code]
    end
  end
end

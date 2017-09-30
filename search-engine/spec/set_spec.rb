describe "Sets" do
  include_context "db"

  KNOWS_SET_TYPES = [
    "archenemy",
    "box",
    "commander",
    "conspiracy",
    "core",
    "duel deck",
    "expansion",
    "from the vault",
    "masterpiece",
    "masters",
    "planechase",
    "premium deck",
    "promo",
    "reprint",
    "starter",
    "un",
    "vanguard",
  ]

  it "all sets have sensible type" do
    db.sets.values.map(&:type).to_set.should eq KNOWS_SET_TYPES.to_set
  end

  let(:regular_sets) { db.sets.values.select{|s|
    s.type == "core" or s.type == "expansion" or s.name =~ /Welcome Deck/
  }.to_set }

  describe "Modern legal sets" do
    let(:start_date) { db.sets["8e"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
    let(:actual) { FormatModern.new.included_sets }
    it { expected.should eq actual }
  end

  describe "Frontier legal sets" do
    let(:start_date) { db.sets["m15"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
    let(:actual) { FormatFrontier.new.included_sets }
    it { expected.should eq actual }
  end

  describe "Standard legal sets" do
    let(:start_date) { db.sets["mr"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
    let(:actual) { FormatStandard.new.rotation_schedule.values.flatten.to_set }
    it do
      expected.should eq actual
    end
  end
end

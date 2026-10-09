load File.expand_path("../../bin/export_sealed_data", __dir__)

describe "Unglued token slots" do
  include_context "db"
  let(:pack) { db.supported_booster_types.fetch("ugl-draft") }

  it "preserves ten physical cards and the reconstructed uncommon pairs" do
    pack.expected_values.values.sum.should eq(10)
    pack.cards.size.should eq(94)
    pack.source_set_codes.should eq(["ugl"])
    pack.packs.each_key do |variant|
      cards = variant.open
      cards.size.should eq(10)
      cards.count{|c| c.is_a?(BoosterToken)}.should be <= 1
      cards.count{|c| c.is_a?(PhysicalCard) && c.rarity == "common"}.should eq(6)
      cards.count{|c| c.is_a?(PhysicalCard) && c.rarity == "rare"}.should eq(1)
      cards.count{|c| c.is_a?(PhysicalCard) && c.rarity == "basic"}.should eq(1)
      if cards.any?{|c| c.is_a?(BoosterToken) && c.name == "Pegasus"}
        cards.select{|c| c.is_a?(PhysicalCard) && c.rarity == "uncommon"}.map(&:name).should satisfy{|names| [["Urza's Contact Lenses"], ["Lexivore"]].include?(names)}
      end
    end
  end

  it "uses U3 for Sheep and Squirrel and U4 for the other uncommon positions" do
    tokens = pack.expected_values.select{|c, _| c.is_a?(BoosterToken)}
    tokens.size.should eq(6)
    tokens.values.sum.should eq(Rational(2, 5))
    tokens.each do |card, weight|
      weight.should eq(Rational(%w[Sheep Squirrel].include?(card.name) ? 3 : 4, 55))
      card.finish.should eq(:nonfoil)
    end
    pack.expected_values.select{|c, _| c.is_a?(PhysicalCard) && c.rarity == "uncommon"}.each_value do |weight|
      weight.should eq(Rational(4, 55))
    end
  end

  it "exports the real token UUID through all sealed formats" do
    token = db.booster_token("tugl/89", :nonfoil)
    sheet = CardSheet.new([token])
    exporter = Struct.new(:db, :uuids).new(db, {})
    ExportFormatterBasic.new(exporter).serialize_sheet(sheet)[:cards].should eq("tugl:89" => 1)
    row = ExportFormatterExtended.new(exporter).serialize_sheet(sheet)[:cards].fetch(0)
    row[:uuid].should eq("88308b13-9d63-5450-8152-54a09e60e259")
    ExportFormatterExperimental.new(exporter).serialize_sheet(sheet)[:cards].should eq(token.uuid => 1)
  end

  it "rejects unresolved token identities rather than silently dropping a slot" do
    lambda { db.booster_token("tugl/999", :nonfoil) }.should raise_error(/exactly one UUID/)
  end

  it "does not infer premium token finishes from a UUID-only index" do
    lambda { db.booster_token("tugl/89", :foil) }.should raise_error(/finish metadata/)
  end

  it "keeps tokens outside normal card searches and includes them in physical pools" do
    db.search("e:ugl").printings.size.should eq(88)
    Sealed.new(db, "48 ugl").call.values.sum.should eq(480)
  end
end

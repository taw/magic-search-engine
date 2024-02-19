describe Pack do
  include_context "db"
  let(:pack_factory) { PackFactory.new(db) }
  let(:pack_ala) { pack_factory.for("ala", "draft") }
  let(:pack_4ed) { pack_factory.for("4ed", nil) }

  ## All these are used just by tests, but it's good to sanity check them

  it "expected_values" do
    pack_ala.expected_values.values.sum.should eq Rational(15, 1)
    pack_4ed.expected_values.values.sum.should eq Rational(15, 1)
  end

  it "#has_foils?" do
    pack_ala.should have_foils
    pack_4ed.should_not have_foils
  end

  it "#cards" do
    pack_ala.cards.size.should eq 249 + 249
    pack_4ed.cards.size.should eq 363 + 0
  end

  it "#foil_cards" do
    pack_ala.foil_cards.size.should eq 249
    pack_4ed.foil_cards.size.should eq 0
  end

  it "#nonfoil_cards" do
    pack_ala.nonfoil_cards.size.should eq 249
    pack_4ed.nonfoil_cards.size.should eq 363
  end
end

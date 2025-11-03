describe "Opening packs smoke test" do
  include_context "db"

  let(:pack_factory) { PackFactory.new(db) }

  it "Opening packs should return something" do
    db.supported_booster_types.each do |code, pack|
      begin
        cards = pack.open
      rescue
        warn "Error opening pack #{code}: #{$!}"
        raise
      end
      cards.should be_a(Array)
      cards.each do |card|
        card.should be_a(PhysicalCard)
      end
    end
  end
end

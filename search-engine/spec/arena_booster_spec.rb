describe "Arena and MTGO Boosters" do
  include_context "db"

  let(:boosters) { db.supported_booster_types.values }
  # What about remastered sets?
  let(:arena_boosters) { boosters.select{|b| b.code =~ /arena/} }
  let(:mtgo_boosters) { boosters.select{|b| b.code =~ /\A(tpr|me1|me2|me3|me4|vma)\z/ } }
  let(:non_legal_boosters) { boosters.select{|b| b.code == "30a" }}
  let(:non_digital_boosters) { boosters - arena_boosters - mtgo_boosters - non_legal_boosters }

  it "Arena boosters contain only Arena cards" do
    arena_boosters.each do |booster|
      booster.cards.all?(&:arena?).should(eq(true), "All cards for #{booster.code} #{booster.name} should be Arena cards")
    end
  end

  it "MTGO exclusive boosters contain only MTGO cards" do
    mtgo_boosters.each do |booster|
      booster.cards.all?(&:mtgo?).should(eq(true), "All cards for #{booster.code} #{booster.name} should be MTGO cards")
    end
  end

  # Most of them are on MTGO as well
  it "Non-digital boosters don't contain any digital exclusive cards" do
    non_digital_boosters.each do |booster|
      booster.cards.all?(&:paper?).should(eq(true), "All cards for #{booster.code} #{booster.name} should be paper cards")
    end
  end
end

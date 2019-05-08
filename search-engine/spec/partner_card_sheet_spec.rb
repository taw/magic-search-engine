describe PartnerCardSheet do
  include_context "db"
  let(:factory) { CardSheetFactory.new(db) }
  let(:uncommon_sheet) { factory.bbd_uncommon_partner }
  let(:rare_mythic_sheet) { factory.bbd_rare_mythic_partner }

  it "unweighted sheet" do
    proc{ uncommon_sheet.random_card }.should raise_error(/Partner sheet can only return 2 cards at time/)
    proc{ uncommon_sheet.random_cards_without_duplicates(1) }.should raise_error(/Partner sheet can only return 2 cards at time/)
    proc{ uncommon_sheet.random_cards_without_duplicates(10) }.should raise_error(/Partner sheet can only return 2 cards at time/)
    uncommon_sheet.cards.size.should eq(10)
    uncommon_sheet.probabilities.should eq uncommon_sheet.cards.map{|c| [c, Rational(1,10)] }.to_h

    # Just roll a bunch of times
    20.times do
      a, b = uncommon_sheet.random_cards_without_duplicates(2)
      a.main_front.partner.should eq(b.main_front)
    end
  end

  it "weighted sheet" do
    proc{ rare_mythic_sheet.random_card }.should raise_error(/Partner sheet can only return 2 cards at time/)
    proc{ rare_mythic_sheet.random_cards_without_duplicates(1) }.should raise_error(/Partner sheet can only return 2 cards at time/)
    proc{ rare_mythic_sheet.random_cards_without_duplicates(10) }.should raise_error(/Partner sheet can only return 2 cards at time/)
    rare_mythic_sheet.cards.size.should eq(12)
    rare_mythic_sheet.probabilities.should eq(
      rare_mythic_sheet.cards.map{|c| [c, c.rarity == "rare" ? Rational(2,22) : Rational(1,22)] }.to_h
    )

    # Just roll a bunch of times
    20.times do
      a, b = rare_mythic_sheet.random_cards_without_duplicates(2)
      a.main_front.partner.should eq(b.main_front)
    end
  end
end

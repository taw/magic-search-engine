describe PartnerCardSheet do
  include_context "db"
  let(:factory) { CardSheetFactory.new(db) }
  let(:uncommons) { factory.bbd_uncommon_partner }

  it "unweighted sheet" do
    proc{ uncommons.random_card }.should raise_error(/Partner sheet can only return 2 cards at time/)
    proc{ uncommons.random_cards_without_duplicates(1) }.should raise_error(/Partner sheet can only return 2 cards at time/)
    proc{ uncommons.random_cards_without_duplicates(10) }.should raise_error(/Partner sheet can only return 2 cards at time/)
    uncommons.cards.size.should eq(10)
    uncommons.probabilities.should eq uncommons.cards.map{|c| [c, Rational(1,10)] }.to_h

    # Just roll a bunch of times
    20.times do
      a, b = uncommons.random_cards_without_duplicates(2)
      a.main_front.partner.should eq(b.main_front)
    end
  end
end

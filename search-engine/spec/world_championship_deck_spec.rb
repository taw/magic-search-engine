describe "World Championship Decks" do
  include_context "db"

  ["wc97", "wc98", "wc99", "wc00", "wc01", "wc02", "wc03", "wc04"].each do |set_code|
    describe "#{set_code}" do
      let(:set) { db.sets[set_code] }
      let(:decks) { set.decks }

      it "every deck contains cards for same player" do
        set.decks.each do |deck|
          numbers = deck.physical_cards.map(&:number)
          prefixes = numbers.map{|n| n[/\A\D+/] }.uniq
          prefixes.size.should eq(1), "#{set_code.upcase} #{set_code} #{deck.name} should have same prefixes, got: #{prefixes.join(", ")}"
        end
      end

      it "mainboard contains non-SB cards" do
        set.decks.each do |deck|
          bad_cards = deck.cards.map(&:last).select{|c| c.number =~ /sb.?\z/ }
          bad_cards.should be_empty, "#{set_code.upcase} #{deck.name}: #{bad_cards.map{|c| "#{c.name} #{c.number}"}}"
        end
      end

      it "sideboard contains SB cards" do
        set.decks.each do |deck|
          bad_cards = deck.sideboard.map(&:last).reject{|c| c.number =~ /sb.?\z/ }
          bad_cards.should be_empty, "#{set_code.upcase} #{deck.name}: #{bad_cards.map{|c| "#{c.name} #{c.number}"}}"
        end
      end

      it "all cards are nonfoil" do
        cards = decks.flat_map(&:physical_cards).uniq
        cards.none?(&:foil).should be(true)
      end

      it "every card card in the set is in one of the decks" do
        cards_in_set = set.physical_cards
        cards_in_decks = set.decks.flat_map(&:physical_cards).uniq
        cards_in_set.should match_array(cards_in_decks)
      end
    end
  end
end

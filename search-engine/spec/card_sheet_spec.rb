describe CardSheet do
  include_context "db"
  let(:factory) { LegacyCardSheetFactory.new(db) }

  %W[basic common uncommon rare mythic].each do |rarity|
    it "rarity #{rarity}" do
      expected = db.search("e:m10 r:#{rarity}").printings
      actual = factory.rarity("m10", rarity).elements.map(&:main_front)
      expected.should match_array(actual)
    end

    it "cards" do
      sheet = factory.rare_mythic("m10")
      sheet.cards.size.should eq(15+53)
      expected = db.search("e:m10 r>=rare").printings
      actual = sheet.cards.map(&:main_front)
      expected.should match_array(actual)
    end
  end

  context "#probabilities" do
    context "typical set" do
      let(:rare_mythic_sheet) { factory.rare_mythic("m10") }
      let(:uncommon_sheet) { factory.rarity("m10", "uncommon") }
      let(:common_sheet) { factory.rarity("m10", "common") }
      let(:basic_sheet) { factory.rarity("m10", "basic") }
      let(:mythic_card) { physical_card("e:m10 baneslayer angel") }
      let(:rare_card) { physical_card("e:m10 birds of paradise") }
      let(:uncommon_card) { physical_card("e:m10 acidic slime") }
      let(:common_card) { physical_card("e:m10 assassinate") }
      let(:basic_card) { physical_card("e:m10 island") }

      it do
        rare_mythic_sheet.probabilities[mythic_card].should eq Rational(1, 121)
        rare_mythic_sheet.probabilities[rare_card].should eq Rational(2, 121)
        uncommon_sheet.probabilities[uncommon_card].should eq Rational(1, 60)
        common_sheet.probabilities[common_card].should eq Rational(1, 101)
        basic_sheet.probabilities[basic_card].should eq Rational(1, 20)
      end
    end

    context "typical set - foil sheet" do
      let(:foil_sheet) { factory.foil("m10") }
      let(:mythic_card) { physical_card("e:m10 baneslayer angel", true) }
      let(:rare_card) { physical_card("e:m10 birds of paradise", true) }
      let(:uncommon_card) { physical_card("e:m10 acidic slime", true) }
      let(:common_card) { physical_card("e:m10 assassinate", true) }
      let(:basic_card) { physical_card("e:m10 island", true) }

      it do
        # These are based on some guessing
        foil_sheet.probabilities[mythic_card].should eq Rational(1, 121) * Rational(3,20)
        foil_sheet.probabilities[rare_card].should eq Rational(2, 121) * Rational(3,20)
        foil_sheet.probabilities[uncommon_card].should eq Rational(1, 60) * Rational(5,20)
        foil_sheet.probabilities[common_card].should eq Rational(1, 20+101) * Rational(12,20)
        foil_sheet.probabilities[basic_card].should eq Rational(1, 20+101) * Rational(12,20)
      end
    end
  end
end

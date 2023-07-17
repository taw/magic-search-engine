describe ColorBalancedCardSheet do
  include_context "db"

  let(:factory) { CardSheetFactory.new(db) }
  let(:nph_commons) { factory.from_query("e:nph r:common", kind: ColorBalancedCardSheet).tap{|s| s.name="common"} }
  let(:jud_commons) { factory.from_query("e:jud r:common", kind: ColorBalancedCardSheet).tap{|s| s.name="common"} }
  let(:rna_commons) { factory.from_query("e:rna r:common", kind: ColorBalancedCardSheet).tap{|s| s.name="common"} }
  let(:mm2_commons) { factory.from_query("e:mm2 r:common", kind: ColorBalancedCardSheet).tap{|s| s.name="common"} }

  it "separates cards by color identity" do
    nph_commons.color_subsheets[0].cards.size.should eq 11
    nph_commons.color_subsheets[1].cards.size.should eq 11
    nph_commons.color_subsheets[2].cards.size.should eq 11
    nph_commons.color_subsheets[3].cards.size.should eq 11
    nph_commons.color_subsheets[4].cards.size.should eq 11
    nph_commons.color_subsheets[5].cards.size.should eq 5
    nph_commons.color_subsheets.size.should eq 6
    nph_commons.cards.size.should eq 60
  end

  describe "weights_for" do
    it "raises error if can't be done" do
      proc{ nph_commons.random_cards_without_duplicates(5) }.should raise_error("nph/common can't color balance for size 5")
      proc{ jud_commons.random_cards_without_duplicates(10) }.should raise_error("jud/common can't color balance for size 10")
    end

    it "probabilities should add up to 1 and be non-negative" do
      [
        nph_commons.adjusted_weights_for(10),
        nph_commons.adjusted_weights_for(9),
        rna_commons.adjusted_weights_for(10),
        rna_commons.adjusted_weights_for(9),
        mm2_commons.adjusted_weights_for(10),
      ].each do |den, nums|
        nums.sum.should eq den
        nums.any?(&:negative?).should be false
      end
    end

    it "probabilities should add up" do
      [
        [nph_commons, 10],
        [nph_commons, 9],
        [rna_commons, 10],
        [rna_commons, 9],
        [mm2_commons, 10],
      ].each do |sheet, k|
        den, nums = sheet.adjusted_weights_for(k)

        ew = 1 + Rational(nums[0], den) * (k-5)
        eu = 1 + Rational(nums[1], den) * (k-5)
        eb = 1 + Rational(nums[2], den) * (k-5)
        er = 1 + Rational(nums[3], den) * (k-5)
        eg = 1 + Rational(nums[4], den) * (k-5)
        ec =     Rational(nums[5], den) * (k-5)

        ew.should eq Rational(k * sheet.color_subsheets[0].elements.size, sheet.elements.size)
        eu.should eq Rational(k * sheet.color_subsheets[1].elements.size, sheet.elements.size)
        eb.should eq Rational(k * sheet.color_subsheets[2].elements.size, sheet.elements.size)
        er.should eq Rational(k * sheet.color_subsheets[3].elements.size, sheet.elements.size)
        eg.should eq Rational(k * sheet.color_subsheets[4].elements.size, sheet.elements.size)
        ec.should eq Rational(k * sheet.color_subsheets[5].elements.size, sheet.elements.size)
      end
    end
  end
end

describe ColorBalancedCardSheet do
  include_context "db"
  let(:factory) { CardSheetFactory.new(db) }
  let(:nph_commons) { factory.from_query("e:nph r:common", kind: ColorBalancedCardSheet) }
  let(:jud_commons) { factory.from_query("e:jud r:common", kind: ColorBalancedCardSheet) }
  let(:rna_commons) { factory.from_query("e:rna r:common", kind: ColorBalancedCardSheet) }
  let(:mm2_commons) { factory.from_query("e:mm2 r:common", kind: ColorBalancedCardSheet) }

  it "separates cards by color identity" do
    nph_commons.w.size.should eq 11
    nph_commons.u.size.should eq 11
    nph_commons.b.size.should eq 11
    nph_commons.r.size.should eq 11
    nph_commons.g.size.should eq 11
    nph_commons.c.size.should eq 5
    nph_commons.elements.size.should eq 60
  end

  describe "weights_for" do
    it "returns nil if can't be done" do
      nph_commons.weights_for(5).should be nil
      jud_commons.weights_for(10).should be nil
    end

    it "probabilities should add up to 1 and be non-negative" do
      [
        nph_commons.weights_for(10),
        nph_commons.weights_for(9),
        rna_commons.weights_for(10),
        rna_commons.weights_for(9),
        mm2_commons.weights_for(10),
      ].each do |den, *nums|
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
        den, *nums = sheet.weights_for(k)
        ew = 1 + Rational(nums[0], den) * (k-5)
        eu = 1 + Rational(nums[1], den) * (k-5)
        eb = 1 + Rational(nums[2], den) * (k-5)
        er = 1 + Rational(nums[3], den) * (k-5)
        eg = 1 + Rational(nums[4], den) * (k-5)
        ec =     Rational(nums[5], den) * (k-5)

        ew.should eq Rational(k * sheet.w.size, sheet.elements.size)
        eu.should eq Rational(k * sheet.u.size, sheet.elements.size)
        eb.should eq Rational(k * sheet.b.size, sheet.elements.size)
        er.should eq Rational(k * sheet.r.size, sheet.elements.size)
        eg.should eq Rational(k * sheet.g.size, sheet.elements.size)
        ec.should eq Rational(k * sheet.c.size, sheet.elements.size)
      end
    end
  end
end

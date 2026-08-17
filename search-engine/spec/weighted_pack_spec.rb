describe WeightedPack do
  include_context "db", "mrd"

  # Any three distinguishable packs will do, the maths doesn't look inside them
  let(:sheet) { CardSheet.new(db.sets["mrd"].printings.first(5).map{|c| PhysicalCard.for(c)}) }
  let(:a) { Pack.new({sheet => 1}) }
  let(:b) { Pack.new({sheet => 2}) }
  let(:c) { Pack.new({sheet => 3}) }

  # Packs don't define ==, so they're compared by identity, and the labels are
  # only here to keep failure messages readable
  def weights(pack)
    names = {a => "a", b => "b", c => "c"}
    pack.packs.map{|p, w| [names.fetch(p), w] }.sort.to_h
  end

  it "leaves a flat pack alone, except for reducing the weights" do
    pack = WeightedPack.new({a => 2, b => 4})
    weights(pack).should eq({"a" => 1, "b" => 2})
    pack.total_weight.should eq 3
  end

  it "flattens a nested pack into the weights it stands for" do
    inner = WeightedPack.new({b => 1, c => 1})
    pack = WeightedPack.new({a => 2, inner => 2})
    # inner is half the pack, and splits its half evenly
    weights(pack).should eq({"a" => 2, "b" => 1, "c" => 1})
    pack.total_weight.should eq 4
  end

  it "adds up a pack reachable both directly and through a subpack" do
    inner = WeightedPack.new({a => 1, b => 1})
    pack = WeightedPack.new({inner => 2, a => 1})
    # inner is 2/3 of the pack and gives half of that back to a, so a is
    # 1/3 + 1/3 = 2/3, not just the 1/3 it was listed with directly
    weights(pack).should eq({"a" => 2, "b" => 1})
    pack.total_weight.should eq 3
  end

  it "adds up a pack reachable through two subpacks" do
    inner1 = WeightedPack.new({a => 1, b => 3})
    inner2 = WeightedPack.new({a => 1, c => 1})
    pack = WeightedPack.new({inner1 => 1, inner2 => 1})
    # a is 1/4 of inner1's half plus 1/2 of inner2's half, so 1/8 + 2/8
    weights(pack).should eq({"a" => 3, "b" => 3, "c" => 2})
    pack.total_weight.should eq 8
  end

  it "opens each pack with the weight it was flattened to" do
    inner = WeightedPack.new({a => 1, b => 1})
    pack = WeightedPack.new({inner => 2, a => 1})
    # expected_values sums each subpack's card counts by its share of the whole,
    # so it's an independent check on the weights
    pack.expected_values.values.sum.should eq Rational(2 * 1 + 1 * 2, 3)
  end
end

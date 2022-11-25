describe "Color Comparison Unit Test" do
  let(:colors) { ["", "b", "bg", "bgr", "bgru", "bgruw", "bgrw", "bgu", "bguw", "bgw", "br", "bru", "bruw", "brw", "bu", "buw", "bw", "g", "gr", "gru", "gruw", "grw", "gu", "guw", "gw", "r", "ru", "ruw", "rw", "u", "uw", "w"].to_set }
  let(:colors0) { Set[""] }
  let(:colors1) { Set["w", "u", "b", "r", "g"] }
  let(:colors_ally) { Set["wu", "ub", "br", "rg", "gw"] }
  let(:colors_enemy) { Set["wb", "ur", "bg", "rw", "gu"] }
  let(:colors2) { Set["wu", "ub", "br", "rg", "gw", "wb", "ur", "bg", "rw", "gu"] }
  let(:colors_shard) { Set["wub", "ubr", "brg", "rgw", "gwu"] }
  let(:colors_wedge) { Set["wur", "ubg", "brw", "rgu", "gwb"] }
  let(:colors3) { Set["wub", "ubr", "brg", "rgw", "gwu", "wur", "ubg", "brw", "rgu", "gwb"] }
  let(:colors4) { Set["bgru", "bgrw", "bguw", "bruw", "gruw"] }
  let(:colors5) { Set["wubrg"] }
  let(:nothing) { Set[] }

  it "= color" do
    colors.each do |c|
      expect_color "=", c, c
    end
  end

  it "spelling variations" do
    expect_color_equal "=", "gr", "=", "rg"
    expect_color_equal "=", "gr", "=", "GR"
    expect_color_equal "=", "gr", "=", "GRRG"
    expect_color_equal "=", "gr", "=", "g r"
  end

  it ">= color" do
    colors.each do |c|
      expect_color ">=", c, colors.select{|cc| cc.chars.to_set >= c.chars.to_set}
    end
  end

  it "<= color" do
    colors.each do |c|
      expect_color "<=", c, colors.select{|cc| cc.chars.to_set <= c.chars.to_set}
    end
  end

  it "> color" do
    colors.each do |c|
      expect_color ">", c, colors.select{|cc| cc.chars.to_set > c.chars.to_set}
    end
  end

  it "< color" do
    colors.each do |c|
      expect_color "<", c, colors.select{|cc| cc.chars.to_set < c.chars.to_set}
    end
  end

  it "ally" do
    expect_color "=", "ally", colors_ally
    expect_color ">=", "ally", colors_ally, colors3, colors4, colors5
    expect_color ">", "ally", colors3, colors4, colors5
    expect_color "<", "ally", colors0, colors1
  end

  # just an alias
  it "allied" do
    expect_color "=", "allied", colors_ally
    expect_color ">=", "allied", colors_ally, colors3, colors4, colors5
    expect_color ">", "allied", colors3, colors4, colors5
    expect_color "<", "allied", colors0, colors1
  end

  it "enemy" do
    expect_color "=", "enemy", colors_enemy
    expect_color ">=", "enemy", colors_enemy, colors3, colors4, colors5
    expect_color ">", "enemy", colors3, colors4, colors5
    expect_color "<", "enemy", colors0, colors1
  end

  it "shard" do
    expect_color "=", "shard", colors_shard
    expect_color ">=", "shard", colors_shard, colors4, colors5
    expect_color ">", "shard", colors4, colors5
    expect_color "<", "shard", colors0, colors1, colors2
  end

  it "wedge" do
    expect_color "=", "wedge", colors_wedge
    expect_color ">=", "wedge", colors_wedge, colors4, colors5
    expect_color ">", "wedge", colors4, colors5
    expect_color "<", "wedge", colors0, colors1, colors2
  end

  it "= number" do
    expect_color "=", "0", colors0
    expect_color "=", "1", colors1
    expect_color "=", "2", colors2
    expect_color "=", "3", colors3
    expect_color "=", "4", colors4
    expect_color "=", "5", colors5
    expect_color "=", "6", nothing
  end

  it "> number" do
    expect_color_equal ">", "0", ">=", "1"
    expect_color_equal ">", "1", ">=", "2"
    expect_color_equal ">", "2", ">=", "3"
    expect_color_equal ">", "3", ">=", "4"
    expect_color_equal ">", "4", "=", "5"
    expect_color ">", "5", nothing
  end

  it "< number" do
    expect_color "<", "0", nothing
    expect_color_equal "<", "1", "=", "0"
    expect_color_equal "<", "2", "<=", "1"
    expect_color_equal "<", "3", "<=", "2"
    expect_color_equal "<", "4", "<=", "3"
    expect_color_equal "<", "5", "<=", "4"
    expect_color "<", "6", colors
  end

  it ">= number" do
    expect_color ">=", "0", colors
    expect_color ">=", "1", colors1, colors2, colors3, colors4, colors5
    expect_color ">=", "2", colors2, colors3, colors4, colors5
    expect_color ">=", "3", colors3, colors4, colors5
    expect_color ">=", "4", colors4, colors5
    expect_color ">=", "5", colors5
    expect_color ">=", "6", nothing
  end

  it "<= number" do
    expect_color "<=", "0", colors0
    expect_color "<=", "1", colors0, colors1
    expect_color "<=", "2", colors0, colors1, colors2
    expect_color "<=", "3", colors0, colors1, colors2, colors3
    expect_color "<=", "4", colors0, colors1, colors2, colors3, colors4
    expect_color "<=", "5", colors
    expect_color "<=", "6", colors
  end

  it "star" do
    expect_color "=", "*", colors
    expect_color ">=", "*", colors
    expect_color "<=", "*", colors
    # Not clear if these should mean c>0 and c<5 instead
    expect_color ">", "*", colors
    expect_color "<", "*", colors
  end

  it "c" do
    expect_color "=", "c", colors0
  end

  # c:mXXX is the same as c>=2 c:XXX
  # any other use of m like c<m is not really supported
  # and generally it's legacy syntax
  it "m" do
    expect_color_equal ">=", "m", ">=", "2"
    expect_color_equal ">=", "mr", ">", "r"
    expect_color_equal ">=", "mrg", ">=", "rg"
  end

  def expect_color(op, s, *expected)
    expected = expected.flat_map{|c| [*c]}.map{|c| c.chars.to_set}.to_set
    Color.matching(op, s).should eq(expected)
  end

  def expect_color_equal(op1, s1, op2, s2)
    Color.matching(op1, s1).should eq(Color.matching(op2, s2))
  end
end

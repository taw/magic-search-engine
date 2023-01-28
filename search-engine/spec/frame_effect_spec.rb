# These are sanity checks not comprehensive specs

describe "frame type and effect queries" do
  include_context "db"

  def printings_matching(&block)
    db.printings.select(&block)
  end

  let(:frame_effects) { db.printings.flat_map(&:frame_effects).uniq }
  let(:frame_types) { db.printings.map(&:frame).uniq }

  it "every frame type has corresponding frame: operator" do
    frame_types.each do |frame_type|
      "frame:#{frame_type}".should return_printings(
        printings_matching{|c| c.frame == frame_type}
      )
    end
  end

  it "every frame effect has corresponding frame: operator" do
    frame_effects.each do |frame_effect|
      "frame:#{frame_effect}".should return_printings(
        printings_matching{|c| c.frame_effects.include?(frame_effect) }
      )
    end
  end

  it "every frame: also works as is:" do
    [*frame_effects, *frame_types].each do |frame|
      next if frame == "draft" # is:draft already used for something else
      next if frame == "fullart" # isFullArt and frameEffects:["fullart"] do not agree, 🤷‍♂️
      assert_search_equal "frame:#{frame}", "is:#{frame}"
    end
  end

  it "frame:colorshifted" do
    assert_search_equal "frame:colorshifted", "e:plc,plist frame:colorshifted"
  end

  it "frame:compasslanddfc" do
    assert_search_equal "e:xln frame:compasslanddfc", "e:xln //"
  end

  it "frame:devoid" do
    assert_search_equal "e:pbfz frame:devoid", "e:pbfz o:devoid"
  end

  it "is:extendedart" do
    assert_include_search "is:extendedart", "e:puma"
  end

  it "frame:legendary" do
    assert_search_equal "e:dom frame:legendary", "e:dom t:legendary -t:planeswalker"
  end

  it "frame:miracle" do
    assert_search_equal "e:avr frame:miracle", "e:avr o:miracle"
  end

  it "frame:mooneldrazidfc" do
    assert_search_equal "e:emn frame:mooneldrazidfc r:uncommon", "e:emn r:uncommon //"
  end

  it "frame:nyxtouched" do
    assert_search_equal "e:ths frame:nyxtouched", "e:ths t:enchantment (t:creature or t:artifact)"
  end

  it "frame:originpwdfc" do
    assert_search_equal "e:ori frame:originpwdfc", "e:ori // t:planeswalker"
  end

  it "frame:sunmoondfc" do
    assert_search_equal "e:isd frame:sunmoondfc", "e:isd //"
  end

  it "frame:tombstone" do
    assert_search_equal "e:tor frame:tombstone", "e:tor (o:flashback or Ichorid)"
  end

  it "is:fullart" do
    assert_search_equal "is:fullart", "is:full"
    assert_include_search "is:fullart", "t:basic e:ust,unh,ugl"
  end

  it "is:textless" do
    assert_include_search "is:fullart", "e:p10"
  end

  it "frame:lesson" do
    assert_include_search "is:lesson", "e:stx t:lesson"
  end
end

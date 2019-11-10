# mtgjson docs also describe some that don't seem to be in use:
# - frame:draft
#
# These are sanity checks not comprehensive specs

describe "frame effect queries" do
  include_context "db"

  it "frame:colorshifted" do
    assert_search_equal "frame:colorshifted", "e:plc frame:colorshifted"
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
end

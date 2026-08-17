describe "Formats - Future Standard" do
  include_context "db"

  # Future Standard is Standard one rotation ahead, so time traveling to just before
  # any rotation must give the same answer as Standard right after it
  describe "one rotation ahead of Standard" do
    let(:rotations) { FormatStandard.new.rotations.map(&:first).sort }

    it do
      rotations.each do |rotation|
        FormatFuture.new(rotation - 1).included_sets.should eq(FormatStandard.new(rotation).included_sets),
          "Future Standard just before #{rotation} should match Standard at #{rotation}"
      end
    end
  end

  describe "next rotation" do
    let(:format) { FormatFuture.new }

    it "drops sets which are about to rotate out" do
      format.included_sets.should_not include("woe")
      format.included_sets.should_not include("blb")
      format.included_sets.should_not include("dsk")
    end

    it "keeps sets which survive the rotation" do
      format.included_sets.should include("fdn")
      format.included_sets.should include("dft")
      format.included_sets.should include("msh")
    end

    it "includes sets which are not released yet" do
      format.included_sets.should include("hob")
    end

    it "is a strict subset of the last known rotation plus new sets" do
      # Every set is either still in Standard, or not released when the current Standard started
      standard_sets = FormatStandard.new.included_sets
      new_sets = format.included_sets - standard_sets
      new_sets.each do |set_code|
        db.sets[set_code].types.should include("preview")
      end
    end
  end

  it "uses Standard ban list" do
    FormatFuture.new.ban_events.should eq(FormatStandard.new.ban_events)
  end

  # Cards banned in Standard but no longer in format after rotation must drop out entirely
  it "banned cards are limited to cards still in format" do
    assert_search_include "banned:future", "Cori-Steel Cutter"
    assert_include_search "banned:standard", "banned:future"
    # Monstrous Rage is banned in Standard, but WOE rotates out
    assert_search_exclude "banned:future", "Monstrous Rage"
  end

  it "queries" do
    assert_search_equal "f:future", %[f:"future standard"]
    assert_search_equal "f:future", "legal:future or restricted:future"
    assert_search_equal_cards "f:future",
      %[
        e:fdn,dft,tdm,fin,eoe,spm,tla,ecl,tmt,sos,msh,hob,fra,trk
        -is:alchemy
        -(Cori-Steel Cutter)
        -(Vivi Ornitier)
        -(Badgermole Cub)
        -(Gran-Gran)
      ]
  end

  # There's no rotation after the last one we know about
  it "is empty once we run out of schedule" do
    last_rotation = FormatStandard.new.rotations.map(&:first).max
    FormatFuture.new(last_rotation).included_sets.should eq(Set[])
    assert_search_results "f:future time:#{last_rotation}"
  end
end

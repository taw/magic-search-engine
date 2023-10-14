describe "is:booster" do
  include_context "db"

  let(:set_types_with_boosters) do
    Set[
      "conspiracy",
      "core",
      "expansion",
      "jumpstart",
      "masters",
      "modern",
      "reprint",
      "starter",
      "two-headed giant",
      "un",
    ]
  end

  it "set has boosters" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}]"
      should_have_boosters = (
        %W[mb1 cmr dbl clb 30a zne who].include?(set_code) or (
          !(set_types_with_boosters & set.types).empty? and
          !%W[ced cei tsb itp s00 cp1 cp2 cp3 w16 w17 gk1 ppod ana oana fmb1 anb plist slx uplist sis md1].include?(set.code)
        )
      )
      should_be_in_other_boosters = (
        %W[tsb exp mps mp2 fmb1 plist sta sunf brr sis slx].include?(set.code)
      )
      if %W[j21 ajmp].include?(set_code)
        # Arena extras
        set.should_not have_boosters, "#{set_pp} should not have boosters"
      elsif should_have_boosters
        set.should have_boosters, "#{set_pp} should have boosters"
      else
        set.should_not have_boosters, "#{set_pp} should not have boosters"
      end
      if should_be_in_other_boosters
        set.should be_in_other_boosters, "#{set_pp} should be included in other boosters"
      else
        set.should_not be_in_other_boosters, "#{set_pp} should not be included in other boosters"
      end
    end
  end

  # Tests for is:booster removed as
  # realistically it would be far too complex

  describe "Arena boosters" do
    let(:pack_factory) { PackFactory.new(db) }

    let(:standard_arena_sets) do
      db.sets.values.select{|s|
        (s.types.include?("standard") or s.code == "ltr") and
        s.types.include?("booster") and
        s.printings.any?(&:arena?) and
        s.code != "ogw"
      }.map(&:code).to_set
    end

    let(:remaster_arena_sets) do
      %W[akr klr].to_set
    end

    it do
      db.sets.each do |set_code, set|
        if standard_arena_sets.include?(set_code)
          pack_factory.for(set_code, "arena").should_not(be_nil, "#{set_code} should have Arena boosters")
          pack_factory.for(set_code, nil).should_not(be_nil, "#{set_code} should have regular boosters")
        elsif remaster_arena_sets.include?(set_code)
          pack_factory.for(set_code, "arena").should_not(be_nil, "#{set_code} should have Arena boosters")
          pack_factory.for(set_code, nil).should(be_nil, "#{set_code} should not have regular boosters")
        else
          pack_factory.for(set_code, "arena").should(be_nil, "#{set_code} should not have Arena boosters")
        end
      end
    end
  end
end

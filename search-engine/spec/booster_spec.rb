describe "is:booster" do
  include_context "db"

  let(:set_types_with_boosters) do
    Set[
      "conspiracy",
      "core",
      "expansion",
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
        %W[mb1 cmb1 cmb2 cmr dbl clb].include?(set_code) or (
          !(set_types_with_boosters & set.types).empty? and
          !%W[ced cei tsb itp s00 cp1 cp2 cp3 w16 w17 gk1 ppod ana oana fmb1 anb plist slx uplist].include?(set.code)
        )
      )
      should_be_in_other_boosters = (
        %W[tsb exp mps mp2 fmb1 plist sta sunf brr].include?(set.code)
      )
      if %W[jmp ajmp].include?(set_code)
        # There are 121 random precon/booster things
        # These could be modelled as 121 boosters, for total of 2420 one-card sheets
        # Or as 121 precons
        # It's not perfect match either way, but I went with 121 precons
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

  it "card is in boosters" do
    db.sets.each do |set_code, set|
      # Exclude planesawlker deck cards
      case set_code
      when "m15"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=269"
      when "kld"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=264 -number:/†/"
      when "aer"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=184 -number:/†/"
      when "akh"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=269"
      when "hou"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=199"
      when "xln"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=279"
      when "rix"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=196"
      when "dom"
        # This also excludes Firesong and Sunspeaker buy-a-box promo
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=269"
      when "ori"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=272"
      when "m19"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=280"
      when "m20"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=280 -number:/†/"
      when "m21"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} (number<=274 or t:basic)"
      when "eld"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=269"
      when "grn", "rna"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=259"
      when "mh1"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=254"
      when "thb"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=254"
      when "iko"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=313 -number:275 -number:275a"
      when "ogw"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} (-t:basic or -number:/a/) -number:/†/"
      when "bfz"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} (-t:basic or -number:/a/)"
      when "war"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=264 -number:/†|★/"
      when "2xm"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=332"
      when "znr"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=280"
      when "arn", "shm"
        # They include † cards
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code}"
      when "ice", "mir", "tmp", "usg", "4ed", "5ed", "6ed"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} -t:basic -number:/†|s/"
      when "cmr"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=361"
      when "klr"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=301"
      when "akr"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=338"
      when "khm"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=285"
      when "tsr"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=410"
      when "stx"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=275 -number:/★/"
      when "sta"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=63 -number:/e/"
      when "mh2"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=303"
      when "afr"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=281 -number:/★/"
      when "mid", "vow"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=277 -number:/†/"
      when "dbl"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=534"
      when "mb1"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=1694 -number:/†/"
      when "zen"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} -number:/a/"
      when "neo"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=302"
      when "snc"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=281"
      when "clb"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=361"
      when "2x2"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=331"
      when "por"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} -number:/†|s|d/"
      when "gpt"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} -number:/★/"
      when "dmu"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=281"
      when "unf"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=244"
      when "bro"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=287 (number<268 or number>=278)"
      else
        if set.has_boosters? or set.in_other_boosters?
          assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} -number:/†|s/"
        else
          assert_search_equal "e:#{set_code} -is:booster", "e:#{set_code}"
        end
      end
    end
  end

  describe "Arena boosters" do
    let(:pack_factory) { PackFactory.new(db) }

    let(:standard_arena_sets) do
      db.sets.values.select{|s|
        s.types.include?("standard") and
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

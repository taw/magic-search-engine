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
        %W[mb1 cmb1].include?(set_code) or (
          !(set_types_with_boosters & set.types).empty? and
          !%W[ced cei tsb itp s00 cp1 cp2 cp3 w16 w17 gk1 ppod ana fmb1].include?(set.code)
        )
      )
      if should_have_boosters
        set.should have_boosters, "#{set_pp} should have boosters"
      else
        set.should_not have_boosters, "#{set_pp} should not have boosters"
      end

      should_be_in_other_boosters = (
        %W[tsb exp mps mp2 fmb1].include?(set.code)
      )
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
      when "eld"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=269"
      when "grn", "rna"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=259"
      when "mh1"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=254"
      when "thb"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=254"
      when "iko"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=274"
      when "ogw"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} (-t:basic or -number:/a/)"
      when "bfz"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} (-t:basic or -number:/a/)"
      when "war"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} number<=264 -number:/†|★/"
      when "arn", "shm"
        # They include † cards
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code}"
      when "ice", "mir", "tmp", "usg", "4ed", "5ed", "6ed"
        assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} -t:basic -number:/†/"
      else
        if set.has_boosters? or set.in_other_boosters?
          assert_search_equal "e:#{set_code} is:booster", "e:#{set_code} -number:/†/"
        else
          assert_search_equal "e:#{set_code} -is:booster", "e:#{set_code}"
        end
      end
    end
  end
end

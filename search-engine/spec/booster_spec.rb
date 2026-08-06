# This test is quite bad now because we have a lot of "boosters" for various randomized promo things
# like box toppers that don't follow traditional rules at all
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
      next if set.types.include?("preview")

      set_pp = "#{set.name} [#{set.code}]"
      should_have_boosters = (
        # hbg is st:alchemy, which is not a booster set type, but it was drafted
        # on Arena out of its own boosters
        %W[mb1 cmr dbl clb 30a zne who sld clu pip slc tle ugin ss1 ss2 ss3 hbg].include?(set_code) or (
          !(set_types_with_boosters & set.types).empty? and
          !%W[ced cei tsb itp s00 cp1 cp2 cp3 w16 w17 gk1 ppod ana oana fmb1 anb plst slx ulst sis md1 big h2r].include?(set.code)
        )
      )
      if %W[j21 ajmp].include?(set_code)
        # Arena extras
        set.types.should_not include("booster"), "#{set_pp} should not have boosters"
      elsif should_have_boosters
        set.types.should include("booster"), "#{set_pp} should have boosters"
      else
        set.types.should_not include("booster"), "#{set_pp} should not have boosters"
      end
    end
  end

  # Tests for is:booster removed as
  # realistically it would be far too complex

  describe "Arena and play boosters" do
    let(:pack_factory) { PackFactory.new(db) }

    let(:standard_arena_sets) do
      db.sets.values.select{|s|
        (s.types.include?("standard") or s.code == "ltr") and
        s.types.include?("booster") and
        # Spoiler season sets have no Arena Limited yet, and their card data is still
        # in flux, so they'd only produce warnings we can't act on until release.
        !s.types.include?("preview") and
        s.printings.any?(&:arena?) and
        (
          # older ones keep getting into remasters and I don't want to maintain a list here, so date cutoff
          # except KTK was imported in whole, without remaster
          s.release_date >= Date.parse("2017-09-29") or
          s.code == "ktk"
        ) and
        # spm never had an Arena Limited release of its own. Wizards could not put the
        # Marvel sets on digital platforms, and shipped a renamed equivalent instead:
        # "One 2025 set, Magic: The Gathering | Marvel's Spider-Man (as well as future
        # Marvel sets) will not be coming to digital Magic platforms. Instead, we will
        # release our first Through the Omenpaths set on September 23."
        # https://magic.wizards.com/en/news/announcements/through-the-omenpaths-and-digital-universes-beyond-updates
        # That Arena set is om1 (Through the Omenpaths), drafted as Pick-Two Draft, not
        # as spm play boosters. spm printings only became Arena-available in June 2026,
        # when Wizards swapped Omenpaths collections over to the real Marvel cards, so
        # the set trips the arena? check without ever having been draftable under this
        # code. 17lands has OM1 PickTwoDraft data and nothing for SPM in any format.
        !%W[big spm].include?(s.code)
      }.map(&:code).to_set
    end

    # Sets which only ever existed on Arena, so they have Arena boosters and no
    # paper draft boosters at all. akr, klr and sir are Arena remasters, hbg is
    # the Alchemy set built out of Battle for Baldur's Gate, om1 is the Universes
    # Within Spider-Man, which is the only way that set was drafted digitally.
    # tpr is MTGO remaster
    # rvr is non-Arena remaster
    let(:arena_only_sets) do
      %W[akr klr sir hbg om1].to_set
    end

    it do
      db.sets.each do |set_code, set|
        if set_code == "sir"
          pack_factory.for(set_code, "arena-1").should_not(be_nil, "#{set_code} should have Arena boosters")
          pack_factory.for(set_code, "arena-2").should_not(be_nil, "#{set_code} should have Arena boosters")
          pack_factory.for(set_code, "arena-3").should_not(be_nil, "#{set_code} should have Arena boosters")
          pack_factory.for(set_code, "arena-4").should_not(be_nil, "#{set_code} should have Arena boosters")
          pack_factory.for(set_code, nil).should(be_nil, "#{set_code} should not have default boosters")
        elsif arena_only_sets.include?(set_code)
          pack_factory.for(set_code, "arena").should_not(be_nil, "#{set_code} should have Arena boosters")
          pack_factory.for(set_code, "draft").should(be_nil, "#{set_code} should not have draft boosters")
        elsif standard_arena_sets.include?(set_code)
          # MKM
          if set.release_date >=  Date.parse("2024-02-09")
            # not sure if these should be xxx-play-arena or just xxx-arena
            # They should be supported, but support is so poor that just print a warning
            if pack_factory.for(set_code, "play-arena") == nil
              warn "#{set_code} should have Arena Play boosters"
            end
            pack_factory.for(set_code, "play").should_not(be_nil, "#{set_code} should have regular boosters")
            pack_factory.for(set_code, "draft").should(be_nil, "#{set_code} should not have draft boosters")
          elsif set_code == "mat"
            pack_factory.for(set_code, "arena").should_not(be_nil, "#{set_code} should have Arena boosters")
            pack_factory.for(set_code, nil).should_not(be_nil, "#{set_code} should have default boosters")
          else
            pack_factory.for(set_code, "arena").should_not(be_nil, "#{set_code} should have Arena boosters")
            pack_factory.for(set_code, "draft").should_not(be_nil, "#{set_code} should have draft boosters")
          end
        else
          pack_factory.for(set_code, "arena").should(be_nil, "#{set_code} should not have Arena boosters")
        end
      end
    end
  end
end

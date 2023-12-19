# These are old tests for the code-based pack system ported to use the new system
#
# Removing boosterfun boosters, as old data wasn't that great anyway
# It should only have old sets and general checks (like which set should or should not have a booster)
#
# I might delete this whole spec at some point
describe PackFactory do
  include_context "db"
  let(:factory) { PackFactory.new(db) }
  let(:variant) { nil }
  let(:foil) { false }
  let(:pack) { factory.for(set_code, variant) }
  let(:ev) { pack.expected_values }

  def card(query, **args)
    query_set_code = args[:set_code] || set_code
    query_foil = args[:foil] || foil
    query += " is:foil" if query_foil
    query += " is:nonfoil" unless query_foil
    # it uses is:booster, but it shouldn't
    physical_card("e:#{query_set_code} is:booster #{query}", query_foil)
  end

  it "Only sets of appropriate types have sealed packs" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}]"
      # Indexer responsibility to set this flag
      if %W[akr klr].include?(set_code)
        factory.for(set_code).should eq(nil), "#{set_pp} should not have regular packs"
        factory.for(set_code, "arena").should_not eq(nil), "#{set_pp} should have Arena packs"
      elsif set_code == "sir"
        factory.for(set_code).should eq(nil), "#{set_pp} should not have regular packs"
        factory.for(set_code, "arena-1").should_not eq(nil), "#{set_pp} should have Arena packs"
      elsif set_code == "jmp" or set_code == "j22"
        factory.for(set_code).should eq(nil), "#{set_pp} should not have regular packs"
        factory.for(set_code, "jumpstart").should_not eq(nil), "#{set_pp} should have Jumpstart packs"
      elsif set_code == "zne"
        factory.for(set_code).should eq(nil), "#{set_pp} should not have regular packs"
        factory.for(set_code, "box-topper").should_not eq(nil), "#{set_pp} should have box topper packs"
      elsif set.has_boosters?
        pack = factory.for(set_code)
        if pack
          pack.should be_a(Pack), "#{set_pp} should have packs"
        else
          warn "#{set_pp} should have packs" # TODO: pending
        end
      else
        pack.should eq(nil), "#{set_pp} should not have packs"
      end
    end
  end

  # There's no guarantee they'll always have them,
  # but it's worth checking exceptions manually
  context "Standard legal sets since Origins generally have non-booster cards" do
    let(:start_date) { db.sets["ori"].release_date }
    let(:regular_sets) { db.sets.values.select{|s|
      s.types.include?("core") or s.types.include?("expansion")
    }.to_set }
    let(:expected_official) {
      regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set - %W[emn soi] + %W[m15 mh1 2xm cmr klr akr tsr mh2 dbl clb 2x2 unf dmr sir ltr cmm who rvr]
    }
    let(:expected_mtgjson_variant) {
      ["mir", "ody", "por", "5ed", "soi", "atq", "drk", "inv", "pcy", "4ed", "7ed", "8ed", "9ed", "10e", "mb1", "gpt", "ala", "jmp", "j22"]
    }
    let(:expected_basics_not_in_boosters) {
      # ice, tmp belongs here for normal boosters, but randomized Starter Deck has basics
      [ "mir", "usg", "4ed", "5ed", "6ed", "zen"]
    }
    let(:expected) {
      expected_official | expected_mtgjson_variant | expected_basics_not_in_boosters
    }
    let(:sets_with_boosters) { db.sets.values.select(&:has_boosters?) }
    let(:sets_with_nonbooster_cards) {
      sets_with_boosters.select{|set| set.printings.any?{|x| !x.in_boosters?} }.map(&:code)
    }
    it do
      sets_with_nonbooster_cards.should match_array expected
    end
  end

  context "Dragon's Maze" do
    let(:set_code) { "dgm" }
    let(:maze_end) { card("maze end") }
    let(:guildgate) { card("azorius guildgate") }
    let(:common) { card("azorius cluestone") }
    let(:uncommon) { card("alive // well") }
    let(:rare) { card("advent of the wurm") }
    let(:mythic) { card("progenitor mimic") }
    let(:shockland) { card("temple garden", set_code: "rtr") }

    context "normal" do
      it do
        ev[guildgate].should eq Rational(23, 242)
        ev[maze_end].should eq Rational(2, 242)
        ev[shockland].should eq Rational(1, 242)
        # 10-(9/40) commons per pack, since 22.5% of packs have foil instead
        ev[common].should eq Rational(391,40) * Rational(1, 60)
        ev[uncommon].should eq Rational(3, 40)
        ev[rare].should eq Rational(1, 40)
        ev[mythic].should eq Rational(1, 80)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        # Definitely no shocklands
        ev[shockland].should eq 0

        # This is all pure guesswork
        # - base rarity rates on foils are guesses
        # - assumption that foiling treats maze's end and guildgates like regular cards is a guess
        # Perhaps it's wrong, and we should instead assume land slot works like basic-land foils?
        ev[guildgate].should eq Rational(9,40) * Rational(12,20) * Rational(1,70)
        ev[common].should eq Rational(9,40) * Rational(12,20) * Rational(1,70)
        ev[uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1,40)
        ev[rare].should eq Rational(9,40) * Rational(3,20) * Rational(2,81)
        ev[mythic].should eq Rational(9,40) * Rational(3,20) * Rational(1,81)
        ev[maze_end].should eq Rational(9,40) * Rational(3,20) * Rational(1,81)
      end
    end
  end

  context "Unhinged" do
    let(:set_code) { "unh" }
    let(:basic) { card("forest") }
    let(:common) { card("artful looter") }
    let(:uncommon) { card("cheatyface") }
    let(:rare) { card("ambiguity") }
    let(:super_secret_tech) { card("super secret tech") }

    context "normal" do
      it do
        ev[basic].should eq Rational(1,5)
        ev[common].should eq Rational(391,40) * Rational(1,55)
        ev[uncommon].should eq Rational(3,40)
        ev[rare].should eq Rational(1,40)
        proc{ super_secret_tech }.should raise_error(/No card matching/)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(9,40) * Rational(12,20) * Rational(1,55+5)
        ev[common].should eq Rational(9,40) * Rational(12,20) * Rational(1,55+5)
        ev[uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1,40)
        ev[rare].should eq Rational(9,40) * Rational(3,20) * Rational(1,40+1)
        ev[super_secret_tech].should eq Rational(9,40) * Rational(3,20) * Rational(1,40+1)
      end
    end
  end

  context "Fate Reforged" do
    let(:set_code) { "frf" }
    let(:basic) { card("forest") }
    let(:gainland) { card("blossoming sands") }
    let(:common) { card("abzan runemark") }
    let(:uncommon) { card("break through the line") }
    let(:rare) { card("atarka world render") }
    let(:mythic) { card("soulfire grand master") }
    let(:fetchland) { card("flooded strand", set_code: "ktk") }

    context "normal" do
      it do
        # Basics only in fat packs - also 2 of each type
        ev[basic].should eq 0
        ev[gainland].should eq Rational(23, 240)
        # 2/121 - change of each shock in KTK
        # This is supposed to be half, 120 has a bit easier math
        ev[fetchland].should eq Rational(1, 120)
        ev[common].should eq Rational(391,40) * Rational(1, 60)
        ev[uncommon].should eq Rational(3, 60)
        ev[rare].should eq Rational(2, 80)
        ev[mythic].should eq Rational(1, 80)
      end
    end

    context "foil" do
      let(:foil) { true }

      # So many questionable assumptions go into this
      it do
        # Definitely no fetchlands
        ev[fetchland].should eq 0
        ev[basic].should eq Rational(9,40) * Rational(12,20) * Rational(1,10+70)
        ev[gainland].should eq Rational(9,40) * Rational(12,20) * Rational(1,10+70)
        ev[common].should eq Rational(9,40) * Rational(12,20) * Rational(1,10+70)
        ev[uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1,60)
        ev[rare].should eq Rational(9,40) * Rational(3,20) * Rational(2,80)
        ev[mythic].should eq Rational(9,40) * Rational(3,20) * Rational(1,80)
      end
    end
  end

  context "Journey Into Nyx" do
    let(:set_code) { "jou" }
    let(:old_gods) { db.search("t:god e:ths,bng").printings.map{|c| PhysicalCard.for(c) } }
    let(:new_gods) { db.search("t:god e:jou").printings.map{|c| PhysicalCard.for(c) } }
    let(:rate) { 4320 }

    # Not the clearest test as they appear all together
    it "God Packs" do
      old_gods.each do |god|
        ev[god].should eq Rational(1, rate)
      end
      new_gods.each do |god|
        ev[god].should eq Rational(1, rate) + Rational(1, 80) * Rational(rate - 1, rate)
      end
    end
  end

  context "Innistrad" do
    let(:set_code) { "isd" }
    let(:dfc_mythic) { card("Garruk Relentless") }
    let(:sfc_mythic) { card("Army of the Damned") }
    let(:foil_dfc_mythic) { card("Garruk Relentless", foil: true) }
    let(:foil_sfc_mythic) { card("Army of the Damned", foil: true) }

    it do
      ev[dfc_mythic].should eq Rational(1, 121)
      ev[sfc_mythic].should eq Rational(1, 121)
      ev[foil_dfc_mythic].should eq Rational(9,40) * Rational(1, 2*59+16) * Rational(3, 20)
      ev[foil_sfc_mythic].should eq Rational(9,40) * Rational(1, 2*59+16) * Rational(3, 20)
    end
  end

  context "Dark Ascension" do
    let(:set_code) { "dka" }
    let(:dfc_mythic) { card("Elbrus, the Binding Blade") }
    let(:sfc_mythic) { card("Beguiler of Wills") }
    let(:foil_dfc_mythic) { card("Elbrus, the Binding Blade", foil: true) }
    let(:foil_sfc_mythic) { card("Beguiler of Wills", foil: true) }

    it do
      ev[dfc_mythic].should eq Rational(1, 80)
      ev[sfc_mythic].should eq Rational(1, 80)
      ev[foil_dfc_mythic].should eq Rational(9,40) * Rational(1, 2*38+12) * Rational(3, 20)
      ev[foil_sfc_mythic].should eq Rational(9,40) * Rational(1, 2*38+12) * Rational(3, 20)
    end
  end

  context "Time Spiral" do
    let(:set_code) { "tsp" }
    let(:basic) { card("forest") }
    let(:common) { card("bonesplitter sliver") }
    let(:uncommon) { card("dread return") }
    let(:rare) { card("academy ruins") }
    let(:timeshifted) { card("akroma", set_code: "tsts") }

    context "non-foil" do
      it do
        ev[basic].should eq 0
        ev[common].should eq Rational(391,40) * Rational(1, 121)
        ev[uncommon].should eq Rational(3, 80)
        ev[rare].should eq Rational(1, 80)
        ev[timeshifted].should eq Rational(1, 121)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(9,40) * Rational(4, 8) * Rational(1, 121+20)
        ev[common].should eq Rational(9,40) * Rational(4, 8) * Rational(1, 121+20)
        ev[uncommon].should eq Rational(9,40) * Rational(2, 8) * Rational(1, 80)
        ev[rare].should eq Rational(9,40) * Rational(1, 8) * Rational(1, 80)
        ev[timeshifted].should eq Rational(9,40) * Rational(1, 8) * Rational(1, 121)
      end
    end
  end

  context "Planar Chaos" do
    let(:set_code) { "plc" }
    let(:common) { card("Mire Boa") }
    let(:uncommon) { card("Necrotic Sliver") }
    let(:rare) { card("Akroma, Angel of Fury") }
    let(:cs_common) { card("Brute Force") }
    let(:cs_uncommon) { card("Blood Knight") }
    let(:cs_rare) { card("Damnation") }

    context "non-foil" do
      it do
        # Even in nonfoil packs (foiling assumes replaces regular common)
        # 8/40 != 3/20
        ev[common].should eq Rational(311, 40) * Rational(1, 40)
        ev[cs_common].should eq Rational(3, 1) * Rational(1, 20)
        # Same 1/20
        ev[uncommon].should eq Rational(2, 40)
        ev[cs_uncommon].should eq Rational(3, 4) * Rational(1, 15)
        # Same 1/40
        ev[rare].should eq Rational(1, 40)
        ev[cs_rare].should eq Rational(1, 4) * Rational(1, 10)
      end
    end

    # Foil rates in atypical sets are a total guess as usual
    context "foil" do
      let(:foil) { true }
      it do
        ev[common].should eq Rational(9,40) * Rational(12,20) * Rational(1, 40+20)
        ev[cs_common].should eq Rational(9,40) * Rational(12,20) * Rational(1, 40+20)
        ev[uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1, 40+15)
        ev[cs_uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1, 40+15)
        ev[rare].should eq Rational(9,40) * Rational(3,20) * Rational(1, 40+10)
        ev[cs_rare].should eq Rational(9,40) * Rational(3,20) * Rational(1, 40+10)
      end
    end
  end

  context "Vintage Masters" do
    let(:set_code) { "vma" }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }
    let(:mythic) { card("r:mythic") }
    let(:special) { card("r:special") }

    context "non-foil" do
      it do
        ev[common].should eq Rational(10, 101)
        ev[uncommon].should eq Rational(3, 80)
        ev[rare].should eq Rational(2, 240)
        ev[mythic].should eq Rational(1, 240)
        ev[special].should eq Rational(1, 480)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        # Numbers based on "non-foil power 9 twice as frequent as a mythic"
        # Actuall they say "about as", so these probably should definitely be rounded
        # in some sensible way
        #
        # Then again, it's a digital-only product, so normal print sheet constraints
        # don't affect it
        ev[common].should eq Rational(471, 480) * Rational(12,20) * Rational(1, 101)
        ev[uncommon].should eq Rational(471, 480) * Rational(5,20) * Rational(1, 80)
        ev[rare].should eq Rational(471, 480) * Rational(3,20) * Rational(4, 489)
        ev[mythic].should eq Rational(471, 480) * Rational(3,20) * Rational(2, 489)
        ev[special].should eq Rational(471, 480) * Rational(3,20) * Rational(1, 489)
      end
    end
  end

  context "Shadows over Innistrad" do
    let(:set_code) { "soi" }
    let(:basic) { card("r:basic") }
    let(:dfc_common) { card("r:common is:dfc") }
    let(:sfc_common) { card("r:common -is:dfc") }
    let(:dfc_uncommon) { card("r:uncommon is:dfc") }
    let(:sfc_uncommon) { card("r:uncommon -is:dfc") }
    let(:dfc_rare) { card("r:rare is:dfc") }
    let(:sfc_rare) { card("r:rare -is:dfc") }
    let(:dfc_mythic) { card("r:mythic is:dfc") }
    let(:sfc_mythic) { card("r:mythic -is:dfc") }

    context "non-foil" do
      it do
        ev[basic].should eq Rational(1, 15)
        ev[sfc_common].should eq (9 - (1/8r) - (9/40r)) * Rational(1, 101)
        ev[sfc_uncommon].should eq Rational(3, 80)
        ev[sfc_rare].should eq Rational(2, 121)
        ev[sfc_mythic].should eq Rational(1, 121)
        ev[dfc_common].should eq Rational(10, 120)
        ev[dfc_uncommon].should eq Rational(4, 120)
        ev[dfc_rare].should eq Rational(1, 8) * Rational(2, 15)
        ev[dfc_mythic].should eq Rational(1, 8) * Rational(1, 15)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(9,40) * Rational(12,20) * Rational(1, 15+105)
        ev[sfc_common].should eq Rational(9,40) * Rational(12,20) * Rational(1, 15+105)
        ev[dfc_common].should eq Rational(9,40) * Rational(12,20) * Rational(1, 15+105)
        ev[sfc_uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1, 100)
        ev[dfc_uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1, 100)
        ev[sfc_rare].should eq Rational(9,40) * Rational(3,20) * Rational(2, 136)
        ev[dfc_rare].should eq Rational(9,40) * Rational(3,20) * Rational(2, 136)
        ev[sfc_mythic].should eq Rational(9,40) * Rational(3,20) * Rational(1, 136)
        ev[dfc_mythic].should eq Rational(9,40) * Rational(3,20) * Rational(1, 136)
      end
    end
  end

  context "Eldritch Moon" do
    let(:set_code) { "emn" }
    let(:basic) { card("r:basic") }
    # Meld cards can have different rarities front/back
    let(:dfc_common) { card("is:front r:common (is:dfc or is:meld)") }
    let(:sfc_common) { card("is:front r:common -(is:dfc or is:meld)") }
    let(:dfc_uncommon) { card("is:front r:uncommon (is:dfc or is:meld)") }
    let(:sfc_uncommon) { card("is:front r:uncommon -(is:dfc or is:meld)") }
    let(:dfc_rare) { card("is:front r:rare (is:dfc or is:meld)") }
    let(:sfc_rare) { card("is:front r:rare -(is:dfc or is:meld)") }
    let(:dfc_mythic) { card("is:front r:mythic (is:dfc or is:meld)") }
    let(:sfc_mythic) { card("is:front r:mythic -(is:dfc or is:meld)") }

    context "non-foil" do
      it do
        ev[sfc_common].should eq (9 - (1/8r) - (9/40r)) * Rational(1, 70)
        ev[sfc_uncommon].should eq Rational(3, 60)
        ev[sfc_rare].should eq Rational(2, 96)
        ev[sfc_mythic].should eq Rational(1, 96)
        ev[dfc_common].should eq Rational(15, 120)
        ev[dfc_uncommon].should eq Rational(6, 120)
        ev[dfc_rare].should eq Rational(1, 8) * Rational(2, 12)
        ev[dfc_mythic].should eq Rational(1, 8) * Rational(1, 12)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        # SOI basics included on foil sheet
        ev[sfc_common].should eq Rational(9,40) * Rational(12,20) * Rational(1, 74 + 15)
        ev[dfc_common].should eq Rational(9,40) * Rational(12,20) * Rational(1, 74 + 15)
        ev[sfc_uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1, 70)
        ev[dfc_uncommon].should eq Rational(9,40) * Rational(5,20) * Rational(1, 70)
        ev[sfc_rare].should eq Rational(9,40) * Rational(3,20) * Rational(2, 108)
        ev[dfc_rare].should eq Rational(9,40) * Rational(3,20) * Rational(2, 108)
        ev[sfc_mythic].should eq Rational(9,40) * Rational(3,20) * Rational(1, 108)
        ev[dfc_mythic].should eq Rational(9,40) * Rational(3,20) * Rational(1, 108)
      end
    end
  end

  context "Dominaria" do
    let(:set_code) { "dom" }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:legendary_uncommon) { card("r:uncommon t:legendary") }
    let(:nonlegendary_uncommon) { card("r:uncommon -t:legendary") }
    let(:legendary_rare) { card("r:rare t:legendary") }
    let(:nonlegendary_rare) { card("r:rare -t:legendary") }
    let(:legendary_mythic) { card("r:mythic t:legendary") }
    let(:nonlegendary_mythic) { card("r:mythic -t:legendary") }

    context "non-foil" do
      it do
        ev[basic].should eq Rational(1, 20)
        ev[common].should eq Rational(391,40) * Rational(1, 101)
        ev[legendary_uncommon].should eq Rational(3, 80)
        ev[legendary_rare].should eq Rational(2, 121)
        ev[legendary_mythic].should eq Rational(1, 121)
        ev[nonlegendary_uncommon].should eq Rational(3, 80)
        ev[nonlegendary_rare].should eq Rational(2, 121)
        ev[nonlegendary_mythic].should eq Rational(1, 121)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(9,40) * Rational(1, 20+101) * Rational(12,20)
        ev[common].should eq Rational(9,40) * Rational(1, 20+101) * Rational(12,20)
        ev[legendary_uncommon].should eq Rational(9,40) * Rational(1, 80) * Rational(5,20)
        ev[legendary_rare].should eq Rational(9,40) * Rational(2, 121) * Rational(3,20)
        ev[legendary_mythic].should eq Rational(9,40) * Rational(1, 121) * Rational(3,20)
        ev[nonlegendary_uncommon].should eq Rational(9,40) * Rational(1, 80) * Rational(5,20)
        ev[nonlegendary_rare].should eq Rational(9,40) * Rational(2, 121) * Rational(3,20)
        ev[nonlegendary_mythic].should eq Rational(9,40) * Rational(1, 121) * Rational(3,20)
      end
    end
  end

  context "War of the Spark" do
    let(:set_code) { "war" }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:planeswalker_uncommon) { card("r:uncommon t:planeswalker -number:/★/") }
    let(:nonplaneswalker_uncommon) { card("r:uncommon -t:planeswalker -number:/★/") }
    let(:planeswalker_rare) { card("r:rare t:planeswalker -number:/★/") }
    let(:nonplaneswalker_rare) { card("r:rare -t:planeswalker -number:/★/") }
    let(:planeswalker_mythic) { card("r:mythic t:planeswalker -number:/★/") }
    let(:nonplaneswalker_mythic) { card("r:mythic -t:planeswalker -number:/★/") }

    context "non-foil" do
      it do
        ev[basic].should eq Rational(1, 15)
        ev[common].should eq Rational(391,40) * Rational(1, 101)
        ev[planeswalker_uncommon].should eq Rational(23, 605)
        ev[planeswalker_rare].should eq Rational(2, 121)
        ev[planeswalker_mythic].should eq Rational(1, 121)
        ev[nonplaneswalker_uncommon].should eq Rational(271, 7260)
        ev[nonplaneswalker_rare].should eq Rational(2, 121)
        ev[nonplaneswalker_mythic].should eq Rational(1, 121)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(9,40) * Rational(1, 15+101) * Rational(12,20)
        ev[common].should eq Rational(9,40) * Rational(1, 15+101) * Rational(12,20)
        ev[planeswalker_uncommon].should eq Rational(9,40) * Rational(1, 80) * Rational(5,20)
        ev[planeswalker_rare].should eq Rational(9,40) * Rational(2, 121) * Rational(3,20)
        ev[planeswalker_mythic].should eq Rational(9,40) * Rational(1, 121) * Rational(3,20)
        ev[nonplaneswalker_uncommon].should eq Rational(9,40) * Rational(1, 80) * Rational(5,20)
        ev[nonplaneswalker_rare].should eq Rational(9,40) * Rational(2, 121) * Rational(3,20)
        ev[nonplaneswalker_mythic].should eq Rational(9,40) * Rational(1, 121) * Rational(3,20)
      end
    end
  end

  # Foil rates are total speculation
  # But there's definitely separate draft and nondraft foils
  context "Conspiracy" do
    let(:set_code) { "cns" }
    let(:common) { card("-is:draft r:common") }
    let(:uncommon) { card("-is:draft r:uncommon") }
    let(:rare) { card("-is:draft r:rare") }
    let(:mythic) { card("-is:draft r:mythic") }
    let(:draft_common) { card("is:draft r:common") }
    let(:draft_uncommon) { card("is:draft r:uncommon") }
    let(:draft_rare) { card("is:draft r:rare") }

    context "non-foil" do
      it do
        ev[common].should eq Rational(391,40) * Rational(1, 80)
        ev[uncommon].should eq Rational(3, 60)
        ev[rare].should eq Rational(2, 80)
        ev[mythic].should eq Rational(1, 80)
        ev[draft_common].should eq Rational(66,67) * Rational(8, 120)
        ev[draft_uncommon].should eq Rational(66,67) * Rational(4, 120)
        ev[draft_rare].should eq Rational(66,67) * Rational(2, 120)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[common].should eq Rational(9,40) * Rational(1, 80) * Rational(12, 20)
        ev[uncommon].should eq Rational(9,40) * Rational(1, 60) * Rational(5, 20)
        ev[rare].should eq Rational(9,40) * Rational(2, 80) * Rational(3, 20)
        ev[mythic].should eq Rational(9,40) * Rational(1, 80) * Rational(3, 20)
        ev[draft_common].should eq Rational(1,67) * Rational(8, 120)
        ev[draft_uncommon].should eq Rational(1,67) * Rational(4, 120)
        ev[draft_rare].should eq Rational(1,67) * Rational(2, 120)
      end
    end
  end

  # Conspiracy ratios and foils are uncertain
  context "Conspiracy 2" do
    let(:set_code) { "cn2" }
    let(:common) { card("-t:conspiracy r:common") }
    let(:uncommon) { card("-t:conspiracy r:uncommon") }
    let(:rare) { card("-t:conspiracy r:rare") }
    let(:mythic) { card("-t:conspiracy r:mythic") }
    let(:conspiracy_common) { card("t:conspiracy r:common") }
    let(:conspiracy_uncommon) { card("t:conspiracy r:uncommon") }
    let(:conspiracy_rare) { card("t:conspiracy r:rare") }
    let(:conspiracy_mythic) { card("t:conspiracy r:mythic") }

    context "non-foil" do
      it do
        ev[common].should eq Rational(391,40) * Rational(1, 85)
        ev[uncommon].should eq Rational(3, 65)
        ev[rare].should eq Rational(2, 106)
        ev[mythic].should eq Rational(1, 106)
        ev[conspiracy_common].should eq Rational(66,67) * Rational(8, 56)
        ev[conspiracy_uncommon].should eq Rational(66,67) * Rational(4,56)
        ev[conspiracy_rare].should eq Rational(66,67) * Rational(2, 56)
        ev[conspiracy_mythic].should eq Rational(66,67) * Rational(1, 56)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[common].should eq Rational(9,40) * Rational(1, 85) * Rational(12, 20)
        ev[uncommon].should eq Rational(9,40) * Rational(1, 65) * Rational(5, 20)
        ev[rare].should eq Rational(9,40) * Rational(2, 106) * Rational(3, 20)
        ev[mythic].should eq Rational(9,40) * Rational(1, 106) * Rational(3, 20)
        ev[conspiracy_common].should eq Rational(1,67) * Rational(8, 56)
        ev[conspiracy_uncommon].should eq Rational(1,67) * Rational(4, 56)
        ev[conspiracy_rare].should eq Rational(1,67) * Rational(2, 56)
        ev[conspiracy_mythic].should eq Rational(1,67) * Rational(1, 56)
      end
    end
  end

  # Foil and contraption rates speculative
  # FIXME: It should balance cards with multiple variants
  context "Unstable" do
    let(:set_code) { "ust" }
    let(:basic) { card("r:basic") }
    let(:steamflogger_boss) { card("Steamflogger Boss") }
    let(:common) { card("-t:contraption r:common Adorable Kitten") }
    let(:variant_common) {  card("-t:contraption r:common Killbot") }
    let(:uncommon) { card("-t:contraption r:uncommon Clever Combo") }
    let(:variant_uncommon) { card("-t:contraption r:uncommon Garbage Elemental") }
    let(:rare) { card("-t:contraption r:rare -border:black Animate Library") }
    let(:variant_rare) { card("-t:contraption r:rare -border:black Very Cryptic Command") }
    let(:mythic) { card("-t:contraption r:mythic") }
    let(:contraption_common) { card("t:contraption r:common") }
    let(:contraption_uncommon) { card("t:contraption r:uncommon") }
    let(:contraption_rare) { card("t:contraption r:rare") }
    let(:contraption_mythic) { card("t:contraption r:mythic") }

    context "non-foil" do
      it do
        ev[basic].should eq Rational(24, 121) * Rational(39, 40)
        ev[steamflogger_boss].should eq Rational(1, 121) * Rational(39, 40)

        # Secret Base is overprinted, so numbers do not add up
        ev[common].should eq Rational(4, 241) * Rational(775, 100)
        ev[variant_common].should eq Rational(4, 241) * Rational(775, 100) * Rational(1, 4)
        ev[uncommon].should eq Rational(3, 60)
        ev[variant_uncommon].should eq Rational(3, 60) * Rational(1, 6)
        ev[rare].should eq Rational(2, 10+35*2)
        ev[variant_rare].should eq Rational(2, 10+35*2) * Rational(1, 6)
        ev[mythic].should eq Rational(1, 10+35*2)
        ev[contraption_common].should eq Rational(8, 205) * Rational(78, 40)
        ev[contraption_uncommon].should eq Rational(4, 205) * Rational(78, 40)
        ev[contraption_rare].should eq Rational(2, 205) * Rational(78, 40)
        ev[contraption_mythic].should eq Rational(1, 205) * Rational(78, 40)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(24, 121) * Rational(1, 40)
        ev[steamflogger_boss].should eq Rational(1, 121) * Rational(1, 40)

        ev[common].should eq Rational(4, 241) * Rational(1, 4) * Rational(12,20)
        ev[variant_common].should eq Rational(4, 241) * Rational(1, 4) * Rational(12,20) * Rational(1, 4)
        ev[uncommon].should eq Rational(1, 60) * Rational(1, 4) * Rational(5,20)
        ev[variant_uncommon].should eq Rational(1, 60) * Rational(1, 4) * Rational(5,20) * Rational(1, 6)
        ev[rare].should eq Rational(2, 80) * Rational(1, 4) * Rational(3,20)
        ev[variant_rare].should eq Rational(2, 80) * Rational(1, 4) * Rational(3,20) * Rational(1, 6)
        ev[mythic].should eq Rational(1, 80) * Rational(1, 4) * Rational(3,20)

        ev[contraption_common].should eq Rational(8, 205) * Rational(2, 40)
        ev[contraption_uncommon].should eq Rational(4, 205) * Rational(2, 40)
        ev[contraption_rare].should eq Rational(2, 205) * Rational(2, 40)
        ev[contraption_mythic].should eq Rational(1, 205) * Rational(2, 40)
      end
    end
  end

  # These are all approximate numbers
  context "Battlebond" do
    let(:set_code) { "bbd" }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:uncommon) { card("-is:partner r:uncommon") }
    let(:rare) { card("-is:partner r:rare") }
    let(:mythic) { card("-is:partner r:mythic") }
    let(:partner_uncommon) { card("is:partner r:uncommon") }
    let(:partner_rare) { card("is:partner r:rare") }

    context "non-foil" do
      let(:partner_mythic) { card("is:partner r:mythic is:nonfoilonly") }
      it do
        ev[basic].should eq Rational(1, 5) # exact
        ev[common].should eq Rational(68, 707)
        ev[uncommon].should eq Rational(111, 3185)
        ev[rare].should eq Rational(18, 1001)
        ev[mythic].should eq Rational(9, 1001) # m:r ratio exact
        ev[partner_uncommon].should eq Rational(4, 91)
        ev[partner_rare].should eq Rational(20, 1001)
        ev[partner_mythic].should eq Rational(10, 1001) # m:r ratio exact
      end
    end

    context "foil" do
      let(:foil) { true }
      let(:partner_mythic) { card("is:partner r:mythic is:foilonly") }
      it do
        ev[basic].should eq Rational(25,91) * Rational(12,20) * Rational(1,101+5) # b:c ratio exact
        ev[common].should eq Rational(25,91) * Rational(12,20) * Rational(1,101+5)
        ev[uncommon].should eq Rational(25,91) * Rational(5,20) * Rational(1,70)
        ev[rare].should eq Rational(25,91) * Rational(3,20) * Rational(2,99)
        ev[mythic].should eq Rational(25,91) * Rational(3,20) * Rational(1,99) # m:r ratio exact
        ev[partner_uncommon].should eq Rational(4, 2821)
        ev[partner_rare].should eq Rational(2, 2821)
        ev[partner_mythic].should eq Rational(1, 2821)  # m:r ratio exact
      end
    end
  end

  context "sets with explicit print sheets" do
    let(:cards) { db.search("++ is:booster e:#{set_code}").printings }
    let(:expected_ev) do
      cards.map do |card|
        sheet = card.print_sheet[0]
        count = card.print_sheet[1..-1].to_i
        [
          PhysicalCard.for(card),
          Rational(count * booster_contents[sheet], sheet_size[sheet])
        ]
      end.to_h
    end

    context "Alliances" do
      let(:set_code) { "all" }
      let(:booster_contents) { {"C"=>8, "U"=>3, "R"=>1} }
      let(:sheet_size) { {"C"=>110, "U"=>110, "R"=>110} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Antiquities" do
      let(:set_code) { "atq" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Arabian Nights" do
      let(:set_code) { "arn" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Chronicles" do
      let(:set_code) { "chr" }
      let(:booster_contents) { {"C"=>9, "U"=>3} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Fallen Empires" do
      let(:set_code) { "fem" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Homelands" do
      let(:set_code) { "hml" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "Legends" do
      let(:set_code) { "leg" }
      let(:booster_contents) { {"C"=>11, "U"=>3, "R"=>1} }
      let(:sheet_size) { {"C"=>121, "U"=>121, "R"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end

    context "The Dark" do
      let(:set_code) { "drk" }
      let(:booster_contents) { {"C"=>6, "U"=>2} }
      let(:sheet_size) { {"C"=>121, "U"=>121} }
      it do
        ev.should eq(expected_ev)
      end
    end
  end

  context "MB1/CMB1/FMB1" do
    let(:mb1_cards) { db.search("++ e:mb1 -number:/†/ -number>=1695").printings }
    let(:fmb1_cards) { db.search("++ e:fmb1").printings }
    let(:cmb1_cards) { db.search("++ e:cmb1").printings }

    let(:mb1_physical_cards) { mb1_cards.map{|c| PhysicalCard.for(c)}.uniq }
    let(:fmb1_physical_cards) { fmb1_cards.map{|c| PhysicalCard.for(c, true)}.uniq }
    let(:cmb1_physical_cards) { cmb1_cards.map{|c| PhysicalCard.for(c)}.uniq }

    context "MB1" do
      let(:set_code) { "mb1" }
      let(:variant) { nil }
      let(:expected_cards) { mb1_physical_cards + fmb1_physical_cards }
      let(:expected_ev) { expected_cards.map{|c| [c, Rational(1,121)] }.to_h }

      it do
        ev.should eq(expected_ev)
      end
    end

    context "CMB1" do
      let(:set_code) { "mb1" }
      let(:variant) { "convention" }
      let(:expected_cards) { mb1_physical_cards + cmb1_physical_cards }
      let(:expected_ev) { expected_cards.map{|c| [c, Rational(1,121)] }.to_h }

      it do
        ev.should eq(expected_ev)
      end
    end
  end

  context "M19" do
    let(:set_code) { "m19" }
    let(:basic) { card("r:basic") }
    let(:nonland_common) { card("r:common -t:land") }
    let(:land_common) { card("r:common t:land") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }
    let(:mythic) { card("r:mythic -is:dfc") }
    let(:bolas) { card("(Nicol Bolas, the Ravager)") }

    context "non-foil" do
      it do
        ev[basic].should eq Rational(1, 30)
        ev[land_common].should eq Rational(1, 30)
        ev[nonland_common].should eq Rational(391,40) * Rational(1, 101)
        ev[uncommon].should eq Rational(3, 80)
        ev[rare].should eq Rational(2, 122)
        ev[mythic].should eq Rational(1, 122)
        ev[bolas].should eq Rational(1, 122)
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(9,40) * Rational(1, 30+101) * Rational(12,20)
        ev[land_common].should eq Rational(9,40) * Rational(1, 30+101) * Rational(12,20)
        ev[nonland_common].should eq Rational(9,40) * Rational(1, 30+101) * Rational(12,20)
        ev[uncommon].should eq Rational(9,40) * Rational(1, 80) * Rational(5,20)
        ev[rare].should eq Rational(9,40) * Rational(2, 122) * Rational(3,20)
        ev[mythic].should eq Rational(9,40) * Rational(1, 122) * Rational(3,20)
        ev[bolas].should eq Rational(9,40) * Rational(1, 122) * Rational(3,20)
      end
    end
  end

  context "M20" do
    let(:set_code) { "m20" }
    let(:nonland_common) { card("r:common -t:land") }
    let(:gainland_common) { card("r:common is:gainland") }
    let(:evolving_wilds) { card("Evolving Wilds") }
    let(:basic) { card("r:basic") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }
    let(:mythic) { card("r:mythic") }

    context "normal" do
      it do
        ev[nonland_common].should eq Rational(1, 101) * Rational(29, 3)
        ev[uncommon].should eq Rational(3, 80)
        ev[rare].should eq Rational(2, 121)
        ev[mythic].should eq Rational(1, 121)
        ev[gainland_common].should eq Rational(1, 31)
        ev[evolving_wilds].should eq Rational(1, 31)
        ev[basic].should eq Rational(1, 31)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        ev[nonland_common].should eq Rational(1,3) * Rational(12,20) * Rational(1,132)
        ev[evolving_wilds].should eq Rational(1,3) * Rational(12,20) * Rational(1,132)
        ev[gainland_common].should eq Rational(1,3) * Rational(12,20) * Rational(1,132)
        ev[basic].should eq Rational(1,3) * Rational(12,20) * Rational(1,132)
        ev[uncommon].should eq Rational(1,3) * Rational(5,20) * Rational(1,80)
        ev[rare].should eq Rational(1,3) * Rational(3,20) * Rational(2,121)
        ev[mythic].should eq Rational(1,3) * Rational(3,20) * Rational(1,121)
      end
    end
  end

  context "M21" do
    let(:set_code) { "m21" }
    let(:nonland_common) { card("r:common -t:land") }
    let(:gainland_common) { card("r:common is:gainland") }
    let(:basic) { card("r:basic") }

    it do
      ev[nonland_common].should eq Rational(1, 101) * Rational(29, 3)
      ev[gainland_common].should eq Rational(6, 120)
      ev[basic].should eq Rational(3, 120)
    end
  end

  context "Alara Premium" do
    let(:pack) { factory.for("ala", "premium") }
    let(:foil) { true }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }
    let(:mythic) { card("r:mythic") }

    context "ALA" do
      let(:set_code) { "ala" }

      it do
        ev[basic].should eq Rational(1, 20)
        ev[common].should eq Rational(10, 221)
        ev[uncommon].should eq Rational(3, 140)
        ev[rare].should eq Rational(2, 35 + 2*123)
        ev[mythic].should eq Rational(1, 35 + 2*123)
      end
    end

    context "CON" do
      let(:set_code) { "con" }

      it do
        ev[common].should eq Rational(10,  221)
        ev[uncommon].should eq Rational(3, 140)
        ev[rare].should eq Rational(2, 35 + 2*123)
        ev[mythic].should eq Rational(1, 35 + 2*123)
      end
    end

    context "ARB" do
      let(:set_code) { "arb" }

      it do
        ev[common].should eq Rational(10, 221)
        ev[uncommon].should eq Rational(3, 140)
        ev[rare].should eq Rational(2, 35 + 2*123)
        ev[mythic].should eq Rational(1, 35 + 2*123)
      end
    end
  end

  # These are largely guesswork
  context "Battlebond" do
    let(:set_code) { "bbd" }

    let(:basic_cards) { physical_cards("r:basic e:#{set_code}") }
    let(:common_cards) { physical_cards("r:common e:#{set_code}") }
    let(:uncommon_cards) { physical_cards("r:uncommon e:#{set_code} -is:partner") }
    let(:rare_cards) { physical_cards("r:rare e:#{set_code} -is:partner") }
    let(:mythic_cards) { physical_cards("r:mythic e:#{set_code} -is:partner is:nonfoil") }
    let(:uncommon_partner_cards) { physical_cards("r:uncommon e:#{set_code} is:partner") }
    let(:rare_partner_cards) { physical_cards("r:rare e:#{set_code} is:partner") }
    let(:mythic_partner_cards) { physical_cards("r:mythic e:#{set_code} is:partner is:nonfoil") }

    let(:foil_basic_cards) { physical_cards("r:basic e:#{set_code}", true) }
    let(:foil_common_cards) { physical_cards("r:common e:#{set_code}", true) }
    let(:foil_uncommon_cards) { physical_cards("r:uncommon e:#{set_code} -is:partner", true) }
    let(:foil_rare_cards) { physical_cards("r:rare e:#{set_code} -is:partner", true) }
    let(:foil_mythic_cards) { physical_cards("r:mythic e:#{set_code} -is:partner is:nonfoil", true) }
    let(:foil_uncommon_partner_cards) { physical_cards("r:uncommon e:#{set_code} is:partner", true) }
    let(:foil_rare_partner_cards) { physical_cards("r:rare e:#{set_code} is:partner", true) }
    let(:foil_mythic_partner_cards) { physical_cards("r:mythic e:#{set_code} is:partner is:foil", true) }

    let(:basics_ev) { basic_cards.map{|c| [c, Rational(1,5)] }.to_h }
    let(:commons_ev) { common_cards.map{|c| [c, Rational(68, 707)] }.to_h }
    let(:uncommons_ev) { uncommon_cards.map{|c| [c, Rational(111, 3185)] }.to_h }
    let(:rares_ev) { rare_cards.map{|c| [c, Rational(18, 1001)] }.to_h }
    let(:mythics_ev) { mythic_cards.map{|c| [c, Rational(9, 1001)] }.to_h }
    let(:uncommon_partners_ev) { uncommon_partner_cards.map{|c| [c, Rational(4, 91)] }.to_h }
    let(:rare_partners_ev) { rare_partner_cards.map{|c| [c, Rational(20, 1001)] }.to_h }
    let(:mythic_partners_ev) { mythic_partner_cards.map{|c| [c, Rational(10, 1001)] }.to_h }

    let(:foil_basics_ev) { foil_basic_cards.map{|c| [c, Rational(15, 9646)] }.to_h }
    let(:foil_commons_ev) { foil_common_cards.map{|c| [c, Rational(15, 9646)] }.to_h }
    let(:foil_uncommons_ev) { foil_uncommon_cards.map{|c| [c, Rational(5, 5096)] }.to_h }
    let(:foil_rares_ev) { foil_rare_cards.map{|c| [c, Rational(5, 6006)] }.to_h }
    let(:foil_mythics_ev) { foil_mythic_cards.map{|c| [c, Rational(5, 12012)] }.to_h }
    let(:foil_uncommon_partners_ev) { foil_uncommon_partner_cards.map{|c| [c, Rational(4, 2821)] }.to_h }
    let(:foil_rare_partners_ev) { foil_rare_partner_cards.map{|c| [c, Rational(2, 2821)] }.to_h }
    let(:foil_mythic_partners_ev) { foil_mythic_partner_cards.map{|c| [c, Rational(1, 2821)] }.to_h }

    let(:expected_ev) {
      {}.merge(
        basics_ev,
        commons_ev,
        uncommons_ev,
        rares_ev,
        mythics_ev,
        uncommon_partners_ev,
        rare_partners_ev,
        mythic_partners_ev,
        foil_basics_ev,
        foil_commons_ev,
        foil_uncommons_ev,
        foil_rares_ev,
        foil_mythics_ev,
        foil_uncommon_partners_ev,
        foil_rare_partners_ev,
        foil_mythic_partners_ev,
      )
    }

    it do
      ev.should eq(expected_ev)
    end
  end

  context "Old foiling - set without basics - 1:100" do
    let(:set_code) { "ulg" }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }

    context "normal" do
      it do
        ev[common].should eq Rational(99, 100) * Rational(11, 55)
        ev[uncommon].should eq Rational(99, 100) * Rational(3, 44)
        ev[rare].should eq Rational(99, 100) * Rational(1, 44)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        ev[common].should eq Rational(1, 100) * Rational(11, 55)
        ev[uncommon].should eq Rational(1, 100) * Rational(3, 44)
        ev[rare].should eq Rational(1, 100) * Rational(1, 44)
      end
    end
  end

  context "Old foiling - set without basics - 1:70" do
    let(:set_code) { "5dn" }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }

    context "normal" do
      it do
        ev[common].should eq Rational(69, 70) * Rational(11, 55)
        ev[uncommon].should eq Rational(69, 70) * Rational(3, 55)
        ev[rare].should eq Rational(69, 70) * Rational(1, 55)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        ev[common].should eq Rational(1, 70) * Rational(11, 55)
        ev[uncommon].should eq Rational(1, 70) * Rational(3, 55)
        ev[rare].should eq Rational(1, 70) * Rational(1, 55)
      end
    end
  end

  context "Old foiling - set with basics - 1:100" do
    let(:set_code) { "mmq" }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }

    context "normal" do
      it do
        ev[basic].should eq 0
        ev[common].should eq Rational(99, 100) * Rational(11, 110)
        ev[uncommon].should eq Rational(99, 100) * Rational(3, 110)
        ev[rare].should eq Rational(99, 100) * Rational(1, 110)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        ev[basic].should eq Rational(1, 100) * Rational(11, 110+20)
        ev[common].should eq Rational(1, 100) * Rational(11, 110+20)
        ev[uncommon].should eq Rational(1, 100) * Rational(3, 110)
        ev[rare].should eq Rational(1, 100) * Rational(1, 110)
      end
    end
  end

  context "Old foiling - set with basics - 1:70" do
    let(:set_code) { "mrd" }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }

    context "normal" do
      it do
        ev[basic].should eq 0
        ev[common].should eq Rational(69, 70) * Rational(11, 110)
        ev[uncommon].should eq Rational(69, 70) * Rational(3, 88)
        ev[rare].should eq Rational(69, 70) * Rational(1, 88)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        ev[basic].should eq Rational(1, 70) * Rational(11, 110+20)
        ev[common].should eq Rational(1, 70) * Rational(11, 110+20)
        ev[uncommon].should eq Rational(1, 70) * Rational(3, 88)
        ev[rare].should eq Rational(1, 70) * Rational(1, 88)
      end
    end
  end

  context "Old foiling - core set with basics in packs - 1:100" do
    let(:set_code) { "7ed" }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }

    context "normal" do
      it do
        ev[basic].should eq Rational(99, 100) * Rational(1, 20)
        ev[common].should eq Rational(99, 100) * Rational(10, 110)
        ev[uncommon].should eq Rational(99, 100) * Rational(3, 110)
        ev[rare].should eq Rational(99, 100) * Rational(1, 110)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        ev[basic].should eq Rational(1, 100) * Rational(1, 20)
        ev[common].should eq Rational(1, 100) * Rational(10, 110)
        ev[uncommon].should eq Rational(1, 100) * Rational(3, 110)
        ev[rare].should eq Rational(1, 100) * Rational(1, 110)
      end
    end
  end

  # 10e has a lot of foil / nonfoil alt arts that get different card numbers
  # but both foil and nonfoil sheets are 121 cards
  context "Old foiling - core set with basics in packs - 1:70" do
    let(:set_code) { "10e" }
    let(:basic) { card("r:basic") }
    let(:common) { card("r:common") }
    let(:uncommon) { card("r:uncommon") }
    let(:rare) { card("r:rare") }

    context "normal" do
      it do
        ev[basic].should eq Rational(69, 70) * Rational(1, 20)
        ev[common].should eq Rational(69, 70) * Rational(10, 121)
        ev[uncommon].should eq Rational(69, 70) * Rational(3, 121)
        ev[rare].should eq Rational(69, 70) * Rational(1, 121)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        ev[basic].should eq Rational(1, 70) * Rational(1, 20)
        ev[common].should eq Rational(1, 70) * Rational(10, 121)
        ev[uncommon].should eq Rational(1, 70) * Rational(3, 121)
        ev[rare].should eq Rational(1, 70) * Rational(1, 121)
      end
    end
  end

  # Pretty much 128.88 == 129
  # but 144.88 is somewhat far from 144, and that formula is uglier
  context "Masterpieces" do
    let(:foil) { true }
    let(:masterpiece_rate) { (1 / (ev[masterpiece] * number_of_masterpiece_cards)).to_f }

    context "BFZ" do
      let(:set_code) { "bfz" }
      let(:official_rate) { 144 }
      let(:approximate_rate) { 144.88888888888889 }
      let(:masterpiece) { card("number=1", set_code: "exp") }
      let(:number_of_masterpiece_cards) { 25 }
      it do
        masterpiece_rate.should eq approximate_rate
      end
    end

    context "OGW" do
      let(:set_code) { "ogw" }
      let(:official_rate) { 144 }
      let(:approximate_rate) { 144.88888888888889 }
      let(:masterpiece) { card("number=26", set_code: "exp") }
      let(:number_of_masterpiece_cards) { 20 }
      it do
        masterpiece_rate.should eq approximate_rate
      end
    end

    context "KLD" do
      let(:set_code) { "kld" }
      let(:official_rate) { 144 }
      let(:approximate_rate) { 144.88888888888889 }
      let(:masterpiece) { card("number=1", set_code: "mps") }
      let(:number_of_masterpiece_cards) { 30 }
      it do
        masterpiece_rate.should eq approximate_rate
      end
    end

    context "AER" do
      let(:set_code) { "aer" }
      let(:official_rate) { 144 }
      let(:approximate_rate) { 144.88888888888889 }
      let(:masterpiece) { card("number=31", set_code: "mps") }
      let(:number_of_masterpiece_cards) { 24 }
      it do
        masterpiece_rate.should eq approximate_rate
      end
    end

    context "AKH" do
      let(:set_code) { "akh" }
      let(:official_rate) { 129 }
      let(:approximate_rate) { 128.88888888888889 }
      let(:masterpiece) { card("number=1", set_code: "mp2") }
      let(:number_of_masterpiece_cards) { 30 }
      it do
        masterpiece_rate.should eq approximate_rate
      end
    end

    context "HOU" do
      let(:set_code) { "hou" }
      let(:official_rate) { 129 }
      let(:approximate_rate) { 128.88888888888889 }
      let(:masterpiece) { card("number=31", set_code: "mp2") }
      let(:number_of_masterpiece_cards) { 24 }
      it do
        masterpiece_rate.should eq approximate_rate
      end
    end
  end

  # They have very different odds, so every rarity is 1:15 chance of foil
  #
  # No guarantee it will apply to all of them, seems so far
  context "Sets with dedicated foil slot" do
    context "A25" do
      let(:set_code) { "a25" }
      let(:common) { card("r:common") }
      let(:uncommon) { card("r:uncommon") }
      let(:rare) { card("r:rare") }
      let(:mythic) { card("r:mythic") }

      context "non-foil" do
        it do
          ev[common].should eq Rational(10, 101)
          ev[uncommon].should eq Rational(3, 80)
          ev[rare].should eq Rational(2, 121)
          ev[mythic].should eq Rational(1, 121)
        end
      end

      context "foil" do
        let(:foil) { true }
        it do
          ev[common].should eq Rational(10, 101) * Rational(1, 14)
          ev[uncommon].should eq Rational(3, 80) * Rational(1, 14)
          ev[rare].should eq Rational(2, 121) * Rational(1, 14)
          ev[mythic].should eq Rational(1, 121) * Rational(1, 14)
        end
      end
    end

    # foil and nonfoil full art basics are only found in "VIP edition"
    context "2XM" do
      let(:set_code) { "2xm" }
      let(:common) { card("r:common") }
      let(:uncommon) { card("r:uncommon") }
      let(:rare) { card("r:rare") }
      let(:mythic) { card("r:mythic") }

      context "non-foil" do
        it do
          ev[common].should eq Rational(8, 91)
          ev[uncommon].should eq Rational(3, 80)
          ev[rare].should eq Rational(4, 121*2+40)
          ev[mythic].should eq Rational(2, 121*2+40)
        end
      end

      context "foil" do
        let(:foil) { true }
        it do
          ev[common].should eq Rational(8, 91) * Rational(2, 13)
          ev[uncommon].should eq Rational(3, 80) * Rational(2, 13)
          ev[rare].should eq Rational(4, 121*2+40) * Rational(2, 13)
          ev[mythic].should eq Rational(2, 121*2+40) * Rational(2, 13)
        end
      end
    end
  end

  # https://magic.wizards.com/en/articles/archive/feature/innistrad-double-feature-product-overview-2021-11-15
  # 4x Innistrad: Midnight Hunt commons
  # 4x Innistrad: Crimson Vow commons
  # 2x Innistrad: Midnight Hunt uncommons
  # 2x Innistrad: Crimson Vow uncommons
  # 1x Innistrad: Midnight Hunt rare or mythic rare
  # 1x Innistrad: Crimson Vow rare or mythic rare
  # 1x Silver screen foil card
  #
  # No information about DFC rarity rates is provided, so I assume:
  # * C SFC EV = C DFC EV (so C is 2/5 of packs, U+R+M is 3/5 of packs)
  # * U/R/M ratios are like in VOW/MID packs
  context "DBL" do
    let(:set_code) { "dbl" }
    let(:basic) { card("r:basic") }
    {
      "mid" => "number<=267",
      "vow" => "number<=554 number>=268",
    }.each do |subset, range|
      let(:common) { card("r:common #{range} -layout:dfc") }
      let(:uncommon) { card("r:uncommon #{range} -layout:dfc") }
      let(:rare) { card("r:rare #{range} -layout:dfc") }
      let(:mythic) { card("r:mythic #{range} -layout:dfc") }
      let(:dfc_common) { card("r:common #{range} layout:dfc") }
      let(:dfc_uncommon) { card("r:uncommon #{range} layout:dfc") }
      let(:dfc_rare) { card("r:rare #{range} layout:dfc") }
      let(:dfc_mythic) { card("r:mythic #{range} layout:dfc") }

      it do
        ev[common].should eq Rational(4, 100)
        ev[uncommon].should eq Rational(2, 83) * (1079/960r)
        ev[rare].should eq Rational(2, 119+35) * (217/220r)
        ev[mythic].should eq Rational(1, 119+35) * (217/220r)

        ev[dfc_common].should eq Rational(4, 100)
        ev[dfc_uncommon].should eq Rational(2, 83) * (249/368r)
        ev[dfc_rare].should eq Rational(2, 119+35) * (77/60r)
        ev[dfc_mythic].should eq Rational(1, 119+35) * (77/60r)
      end
    end
  end

  context "30A" do
    let(:set_code) { "30a" }
    let(:basic) { card("r:basic number<=297") }
    let(:common) { card("r:common number<=297") }
    let(:uncommon) { card("r:uncommon number<=297") }
    let(:rare) { card("r:rare number<=297 -is:dual") }
    let(:dual) { card("r:rare number<=297 is:dual") }
    let(:retro_basic) { card("r:basic number>297") }
    let(:retro_common) { card("r:common number>297") }
    let(:retro_uncommon) { card("r:uncommon number>297") }
    let(:retro_rare) { card("r:rare number>297 -is:dual") }
    let(:retro_dual) { card("r:rare number>297 is:dual") }

    it do
      ev[basic].should eq Rational(2, 15)
      ev[common].should eq Rational(7, 74)
      ev[uncommon].should eq Rational(3, 95)
      ev[rare].should eq Rational(1, 123)
      ev[dual].should eq Rational(2, 123)
      ev[retro_basic].should eq Rational(1, 15)
      ev[retro_common].should eq Rational(4, 3*95 + 4*74) * Rational(7, 10) * Rational(830, 827)
      ev[retro_uncommon].should eq Rational(3, 3*95 + 4*74) * Rational(7, 10) * Rational(830, 827)
      ev[retro_rare].should eq Rational(1, 123) * Rational(3, 10) * Rational(820, 827)
      ev[retro_dual].should eq Rational(2, 123) * Rational(3, 10) * Rational(820, 827)
    end
  end
end

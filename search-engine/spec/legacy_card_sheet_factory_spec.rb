describe LegacyCardSheetFactory do
  include_context "db"
  let(:factory) { LegacyCardSheetFactory.new(db) }
  let(:pack_factory) { LegacyPackFactory.new(db) }

  context "Masterpieces" do
    let(:sheet) { factory.masterpieces_for(set_code) }
    let(:masterpieces) { sheet.elements.map(&:main_front) }
    let(:expected_masterpieces) do
      db.sets[masterpieces_set_code]
        .printings
        .select{|c| masterpieces_range === c.number.to_i }
    end

    context "bfz" do
      let(:set_code) { "bfz" }
      let(:masterpieces_set_code) { "exp" }
      let(:masterpieces_range) { 1..25 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "ogw" do
      let(:set_code) { "ogw" }
      let(:masterpieces_set_code) { "exp" }
      let(:masterpieces_range) { 26..45 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "kld" do
      let(:set_code) { "kld" }
      let(:masterpieces_set_code) { "mps" }
      let(:masterpieces_range) { 1..30 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "aer" do
      let(:set_code) { "aer" }
      let(:masterpieces_set_code) { "mps" }
      let(:masterpieces_range) { 31..54 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "akh" do
      let(:set_code) { "akh" }
      let(:masterpieces_set_code) { "mp2" }
      let(:masterpieces_range) { 1..30 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "hou" do
      let(:set_code) { "hou" }
      let(:masterpieces_set_code) { "mp2" }
      let(:masterpieces_range) { 31..54 }
      it { masterpieces.should eq(expected_masterpieces) }
    end
  end

  context "Dragon's Maze" do
    let(:land_sheet) { factory.dgm_land }
    let(:common_sheet) { factory.dgm_common }
    let(:uncommon_sheet) { factory.rarity("dgm", "uncommon") }
    let(:rare_mythic_sheet) { factory.dgm_rare_mythic }
    let(:rtr_rare_mythic_sheet) { factory.rare_mythic("rtr") }
    let(:gtc_rare_mythic_sheet) { factory.rare_mythic("gtc") }

    let(:guildgate_card) { physical_card("simic guilddate e:dgm") }
    let(:rtr_shockland){ physical_card("Overgrown Tomb e:rtr") }
    let(:gtc_shockland) { physical_card("Breeding Pool e:gtc") }
    let(:mazes_end) { physical_card("Maze's End e:dgm") }

    let(:common_card) { physical_card("Azorius Cluestone e:dgm") }
    let(:uncommon_card) { physical_card("Korozda Gorgon e:dgm") }
    let(:rare_card) { physical_card("Emmara Tandris e:dgm") }
    let(:mythic_card) { physical_card("Blood Baron of Vizkopa e:dgm") }

    # According to official data, Chance of opening "a shockland" in DGM booster
    # is half of what it was in DGM booster. So individually they are 4x rarer
    #
    # Presumably Maze's end should be about as frequent as other mythics,
    # so 1/121 packs of large set [53 rares 15 mythics]
    # or 1/80 packs of small set [35 rares 10 mythics]
    it "Special land sheet" do
      (5 * rtr_rare_mythic_sheet.probabilities[rtr_shockland]).should eq Rational(10, 121)
      (5 * gtc_rare_mythic_sheet.probabilities[gtc_shockland]).should eq Rational(10, 121)
      (10 * land_sheet.probabilities[rtr_shockland]).should eq Rational(5, 121)
      land_sheet.probabilities[mazes_end].should eq Rational(1, 121)
      (10*land_sheet.probabilities[guildgate_card]).should eq Rational(115, 121)
    end

    it "Rarities on other sheets (corrected for land sheet and split cards)" do
      common_sheet.probabilities[common_card].should eq Rational(1, 60)
      uncommon_sheet.probabilities[uncommon_card].should eq Rational(1, 40)
      rare_mythic_sheet.probabilities[rare_card].should eq Rational(2, 80)
      rare_mythic_sheet.probabilities[mythic_card].should eq Rational(1, 80)
    end

    it "Cards for land sheet don't appear on normal sheet" do
      common_sheet.probabilities[guildgate_card].should eq 0
      rare_mythic_sheet.probabilities[mazes_end].should eq 0
    end
  end

  context "Unhinged" do
    context "rare sheet" do
      let(:rare_sheet) { factory.rare_mythic("unh") }
      let(:ambiguity) { physical_card("ambiguity", false) }
      let(:super_secret_tech) { physical_card("super secret tech", false) }

      it do
        rare_sheet.probabilities[ambiguity].should eq Rational(1, 40)
        rare_sheet.probabilities[super_secret_tech].should eq 0
      end
    end

    context "foil sheet" do
      let(:unhinged_foil_rares) { factory.unhinged_foil_rares }
      let(:ambiguity) { physical_card("ambiguity", true) }
      let(:super_secret_tech) { physical_card("super secret tech", true) }

      it do
        unhinged_foil_rares.probabilities[ambiguity].should eq Rational(1, 41)
        unhinged_foil_rares.probabilities[super_secret_tech].should eq Rational(1, 41)
      end
    end
  end

  context "flip cards" do
    let(:pack) { pack_factory.for(set_code) }
    let(:number_of_cards) { pack.nonfoil_cards.size }
    let(:number_of_basics) { factory.rarity(set_code, "basic").cards.size }
    let(:number_of_commons) { factory.rarity(set_code, "common").cards.size }
    let(:number_of_uncommons) { factory.rarity(set_code, "uncommon").cards.size }
    let(:number_of_rares) { factory.rare_mythic(set_code).cards.size }

    describe "Champions of Kamigawa" do
      let(:set_code) { "chk" }
      it do
        number_of_cards.should eq(88+89+110)
        number_of_rares.should eq(88)
        # TODO: Brothers Yamazaki alt art
        number_of_uncommons.should eq(88+1)
        number_of_commons.should eq(110)
        number_of_basics.should eq(20)
      end
    end

    describe "Betrayers of Kamigawa" do
      let(:set_code) { "bok" }
      it do
        number_of_cards.should eq(55+55+55)
        number_of_rares.should eq(55)
        number_of_uncommons.should eq(55)
        number_of_commons.should eq(55)
      end
    end

    describe "Saviors of Kamigawa" do
      let(:set_code) { "sok" }
      it do
        number_of_cards.should eq(55+55+55)
        number_of_rares.should eq(55)
        number_of_uncommons.should eq(55)
        number_of_commons.should eq(55)
      end
    end
  end

  context "physical cards are properly setup" do
    describe "Dissention" do
      let(:pack) { pack_factory.for("dis") }
      let(:rares) { factory.rarity("dis", "uncommon").cards }
      let(:uncommons) { factory.rarity("dis", "uncommon").cards }
      let(:commons) { factory.rarity("dis", "common").cards }
      it do
        pack.nonfoil_cards.size.should eq(60+60+60)
        # 5 rares are split
        rares.size.should eq(60)
        # 5 uncommons are split
        uncommons.size.should eq(60)
        commons.size.should eq(60)
        # split cards setup correctly
        uncommons.map(&:name).should include("Trial // Error")
      end
    end
  end

  # TODO: dfc / aftermath / meld cards

  it "Masters Edition 4" do
    basics = factory.rarity("me4", "basic").cards.map(&:name).uniq
    basics.should match_array(["Urza's Mine", "Urza's Power Plant", "Urza's Tower"])
  end

  it "Origins" do
    mythics = factory.rare_mythic("ori").cards.select{|c| c.rarity == "mythic"}.map(&:name)
    mythics.should match_array([
      "Alhammarret's Archive",
      "Archangel of Tithes",
      "Avaricious Dragon",
      "Chandra, Fire of Kaladesh",
      "Day's Undoing",
      "Demonic Pact",
      "Disciple of the Ring",
      "Erebos's Titan",
      "Kytheon, Hero of Akros",
      "Jace, Vryn's Prodigy",
      "Liliana, Heretical Healer",
      "Nissa, Vastwood Seer",
      "Pyromancer's Goggles",
      "Starfield of Nyx",
      "The Great Aurora",
      "Woodland Bellower"
    ])
  end

  context "Innistrad" do
    let(:probabilities) { factory.isd_dfc.probabilities }
    let(:mythic) { physical_card("e:isd Garruk Relentless") }
    let(:rare) { physical_card("e:isd Bloodline Keeper") }
    let(:uncommon) { physical_card("e:isd Civilized Scholar") }
    let(:common) { physical_card("e:isd Delver of Secrets") }

    it do
      probabilities[mythic].should eq Rational(1, 121)
      probabilities[rare].should eq Rational(2, 121)
      probabilities[uncommon].should eq Rational(6, 121)
      probabilities[common].should eq Rational(11, 121)
    end
  end

  context "Dark Ascension" do
    let(:probabilities) { factory.dka_dfc.probabilities }
    let(:mythic) { physical_card("e:dka Elbrus, the Binding Blade") }
    let(:rare) { physical_card("e:dka Ravenous Demon") }
    let(:uncommon) { physical_card("e:dka Soul Seizer") }
    let(:common) { physical_card("e:dka Chosen of Markov") }

    it do
      probabilities[mythic].should eq Rational(1, 80)
      probabilities[rare].should eq Rational(2, 80)
      probabilities[uncommon].should eq Rational(6, 80)
      probabilities[common].should eq Rational(12, 80)
    end
  end

  context "ABUR basic lands" do
    let(:common_sheet) { factory.explicit_common(set_code).probabilities }
    let(:uncommon_sheet) { factory.explicit_uncommon(set_code).probabilities }
    let(:rare_sheet) { factory.explicit_rare(set_code).probabilities }

    let(:common_cards) { physical_cards("r:common e:#{set_code}") }
    let(:uncommon_cards) { physical_cards("r:uncommon e:#{set_code}") }
    let(:rare_cards) { physical_cards("r:rare e:#{set_code}") }

    let(:commons_once) { common_cards.map{|c| [c, Rational(1,121)] }.to_h }
    let(:uncommons_once) { uncommon_cards.map{|c| [c, Rational(1,121)] }.to_h }
    let(:rares_once) { rare_cards.map{|c| [c, Rational(1,121)] }.to_h }

    context "Limited Edition Alpha" do
      let(:set_code) { "lea" }

      let(:plains_286) { physical_card("e:lea plains number=286") }
      let(:plains_287) { physical_card("e:lea plains number=287") }
      let(:island_288) { physical_card("e:lea island number=288") }
      let(:island_289) { physical_card("e:lea island number=289") }
      let(:swamp_290) { physical_card("e:lea swamp number=290") }
      let(:swamp_291) { physical_card("e:lea swamp number=291") }
      let(:mountain_292) { physical_card("e:lea mountain number=292") }
      let(:mountain_293) { physical_card("e:lea mountain number=293") }
      let(:forest_294) { physical_card("e:lea forest number=294") }
      let(:forest_295) { physical_card("e:lea forest number=295") }

      it "common" do
        common_sheet.should eq commons_once.merge(
          plains_286 => Rational(5, 121),
          plains_287 => Rational(4, 121),
          island_288 => Rational(5, 121),
          island_289 => Rational(5, 121),
          swamp_290 => Rational(5, 121),
          swamp_291 => Rational(4, 121),
          mountain_292 => Rational(5, 121),
          mountain_293 => Rational(4, 121),
          forest_294 => Rational(5, 121),
          forest_295 => Rational(5, 121),
        )
      end

      it "uncommon" do
        uncommon_sheet.should eq uncommons_once.merge(
          plains_286 => Rational(3, 121),
          plains_287 => Rational(3, 121),
          island_288 => Rational(1, 121),
          island_289 => Rational(1, 121),
          swamp_290 => Rational(3, 121),
          swamp_291 => Rational(3, 121),
          mountain_292 => Rational(3, 121),
          mountain_293 => Rational(3, 121),
          forest_294 => Rational(3, 121),
          forest_295 => Rational(3, 121),
        )
      end

      it "rare" do
        rare_sheet.should eq rares_once.merge(
          island_288 => Rational(3, 121),
          island_289 => Rational(2, 121),
        )
      end
    end

    context "Limited Edition Beta" do
      let(:set_code) { "leb" }

      let(:plains_288) { physical_card("e:leb plains number=288") }
      let(:plains_289) { physical_card("e:leb plains number=289") }
      let(:plains_290) { physical_card("e:leb plains number=290") }
      let(:island_291) { physical_card("e:leb island number=291") }
      let(:island_292) { physical_card("e:leb island number=292") }
      let(:island_293) { physical_card("e:leb island number=293") }
      let(:swamp_294) { physical_card("e:leb swamp number=294") }
      let(:swamp_295) { physical_card("e:leb swamp number=295") }
      let(:swamp_296) { physical_card("e:leb swamp number=296") }
      let(:mountain_297) { physical_card("e:leb mountain number=297") }
      let(:mountain_298) { physical_card("e:leb mountain number=298") }
      let(:mountain_299) { physical_card("e:leb mountain number=299") }
      let(:forest_300) { physical_card("e:leb forest number=300") }
      let(:forest_301) { physical_card("e:leb forest number=301") }
      let(:forest_302) { physical_card("e:leb forest number=302") }

      it "common" do
        common_sheet.should eq commons_once.merge(
          plains_288 => Rational(2, 121),
          plains_289 => Rational(3, 121),
          plains_290 => Rational(3, 121),
          island_291 => Rational(3, 121),
          island_292 => Rational(4, 121),
          island_293 => Rational(3, 121),
          swamp_294 => Rational(3, 121),
          swamp_295 => Rational(3, 121),
          swamp_296 => Rational(3, 121),
          mountain_297 => Rational(3, 121),
          mountain_298 => Rational(3, 121),
          mountain_299 => Rational(4, 121),
          forest_300 => Rational(3, 121),
          forest_301 => Rational(3, 121),
          forest_302 => Rational(3, 121),
        )
      end

      it "uncommon" do
        uncommon_sheet.should eq uncommons_once.merge(
          plains_288 => Rational(2, 121),
          plains_289 => Rational(2, 121),
          plains_290 => Rational(2, 121),
          island_292 => Rational(1, 121),
          island_293 => Rational(1, 121),
          swamp_294 => Rational(2, 121),
          swamp_295 => Rational(2, 121),
          swamp_296 => Rational(2, 121),
          mountain_297 => Rational(2, 121),
          mountain_298 => Rational(2, 121),
          mountain_299 => Rational(2, 121),
          forest_300 => Rational(2, 121),
          forest_301 => Rational(2, 121),
          forest_302 => Rational(2, 121),
        )
      end

      it "rare" do
        rare_sheet.should eq rares_once.merge(
          island_291 => Rational(2, 121),
          island_292 => Rational(2, 121),
        )
      end
    end

    context "Unlimited / 2nd Edition" do
      let(:set_code) { "2ed" }

      let(:plains_288) { physical_card("e:2ed plains number=288") }
      let(:plains_289) { physical_card("e:2ed plains number=289") }
      let(:plains_290) { physical_card("e:2ed plains number=290") }
      let(:island_291) { physical_card("e:2ed island number=291") }
      let(:island_292) { physical_card("e:2ed island number=292") }
      let(:island_293) { physical_card("e:2ed island number=293") }
      let(:swamp_294) { physical_card("e:2ed swamp number=294") }
      let(:swamp_295) { physical_card("e:2ed swamp number=295") }
      let(:swamp_296) { physical_card("e:2ed swamp number=296") }
      let(:mountain_297) { physical_card("e:2ed mountain number=297") }
      let(:mountain_298) { physical_card("e:2ed mountain number=298") }
      let(:mountain_299) { physical_card("e:2ed mountain number=299") }
      let(:forest_300) { physical_card("e:2ed forest number=300") }
      let(:forest_301) { physical_card("e:2ed forest number=301") }
      let(:forest_302) { physical_card("e:2ed forest number=302") }

      it "common" do
        common_sheet.should eq commons_once.merge(
          plains_288 => Rational(2, 121),
          plains_289 => Rational(3, 121),
          plains_290 => Rational(3, 121),
          island_291 => Rational(3, 121),
          island_292 => Rational(4, 121),
          island_293 => Rational(3, 121),
          swamp_294 => Rational(3, 121),
          swamp_295 => Rational(3, 121),
          swamp_296 => Rational(3, 121),
          mountain_297 => Rational(4, 121),
          mountain_298 => Rational(3, 121),
          mountain_299 => Rational(3, 121),
          forest_300 => Rational(3, 121),
          forest_301 => Rational(3, 121),
          forest_302 => Rational(3, 121),
        )
      end

      it "uncommon" do
        uncommon_sheet.should eq uncommons_once.merge(
          plains_288 => Rational(2, 121),
          plains_289 => Rational(2, 121),
          plains_290 => Rational(2, 121),
          island_291 => Rational(1, 121),
          island_292 => Rational(1, 121),
          swamp_294 => Rational(2, 121),
          swamp_295 => Rational(2, 121),
          swamp_296 => Rational(2, 121),
          mountain_297 => Rational(2, 121),
          mountain_298 => Rational(2, 121),
          mountain_299 => Rational(2, 121),
          forest_300 => Rational(2, 121),
          forest_301 => Rational(2, 121),
          forest_302 => Rational(2, 121),
        )
      end

      it "rare" do
        rare_sheet.should eq rares_once.merge(
          island_292 => Rational(2, 121),
          island_293 => Rational(2, 121),
        )
      end
    end

    context "Revised / 3rd Edition" do
      let(:set_code) { "3ed" }

      let(:plains_292) { physical_card("e:3ed plains number=292") }
      let(:plains_293) { physical_card("e:3ed plains number=293") }
      let(:plains_294) { physical_card("e:3ed plains number=294") }
      let(:island_295) { physical_card("e:3ed island number=295") }
      let(:island_296) { physical_card("e:3ed island number=296") }
      let(:island_297) { physical_card("e:3ed island number=297") }
      let(:swamp_298) { physical_card("e:3ed swamp number=298") }
      let(:swamp_299) { physical_card("e:3ed swamp number=299") }
      let(:swamp_300) { physical_card("e:3ed swamp number=300") }
      let(:mountain_301) { physical_card("e:3ed mountain number=301") }
      let(:mountain_302) { physical_card("e:3ed mountain number=302") }
      let(:mountain_303) { physical_card("e:3ed mountain number=303") }
      let(:forest_304) { physical_card("e:3ed forest number=304") }
      let(:forest_305) { physical_card("e:3ed forest number=305") }
      let(:forest_306) { physical_card("e:3ed forest number=306") }

      it "common" do
        common_sheet.should eq commons_once.merge(
          plains_292 => Rational(2, 121),
          plains_293 => Rational(3, 121),
          plains_294 => Rational(3, 121),
          island_295 => Rational(3, 121),
          island_296 => Rational(4, 121),
          island_297 => Rational(3, 121),
          swamp_298 => Rational(3, 121),
          swamp_299 => Rational(3, 121),
          swamp_300 => Rational(3, 121),
          mountain_301 => Rational(4, 121),
          mountain_302 => Rational(3, 121),
          mountain_303 => Rational(3, 121),
          forest_304 => Rational(3, 121),
          forest_305 => Rational(2, 121),
          forest_306 => Rational(4, 121),
        )
      end

      it "uncommon" do
        uncommon_sheet.should eq uncommons_once.merge(
          plains_292 => Rational(3, 121),
          plains_293 => Rational(2, 121),
          plains_294 => Rational(1, 121),
          island_296 => Rational(1, 121),
          island_297 => Rational(1, 121),
          swamp_298 => Rational(3, 121),
          swamp_299 => Rational(3, 121),
          mountain_301 => Rational(2, 121),
          mountain_302 => Rational(2, 121),
          mountain_303 => Rational(2, 121),
          forest_304 => Rational(3, 121),
          forest_305 => Rational(2, 121),
          forest_306 => Rational(1, 121),
        )
      end

      it "rare" do
        rare_sheet.should eq rares_once
      end
    end
  end
end

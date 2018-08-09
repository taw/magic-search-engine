describe CardSheetFactory do
  include_context "db"
  let(:factory) { CardSheetFactory.new(db) }
  let(:pack_factory) { PackFactory.new(db) }

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
      let(:masterpieces_set_code) { "mps_akh" }
      let(:masterpieces_range) { 1..30 }
      it { masterpieces.should eq(expected_masterpieces) }
    end

    context "hou" do
      let(:set_code) { "hou" }
      let(:masterpieces_set_code) { "mps_akh" }
      let(:masterpieces_range) { 31..54 }
      it { masterpieces.should eq(expected_masterpieces) }
    end
  end

  context "Dragon's Maze" do
    let(:land_sheet) { factory.dgm_land }
    let(:common_sheet) { factory.dgm_common }
    let(:uncommon_sheet) { factory.rarity("dgm", "uncommon") }
    let(:rare_mythic_sheet) { factory.dgm_rare_mythic }
    let(:rtr_rare_mythic_sheet) { factory.rare_or_mythic("rtr") }
    let(:gtc_rare_mythic_sheet) { factory.rare_or_mythic("gtc") }

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
      let(:rare_sheet) { factory.rare_or_mythic("uh") }
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
    let(:number_of_rares) { factory.rare_or_mythic(set_code).cards.size }

    describe "Champions of Kamigawa" do
      let(:set_code) { "chk" }
      it do
        number_of_cards.should eq(88+89+110+20)
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
      let(:pack) { pack_factory.for("di") }
      let(:rares) { factory.rarity("di", "uncommon").cards }
      let(:uncommons) { factory.rarity("di", "uncommon").cards }
      let(:commons) { factory.rarity("di", "common").cards }
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
    mythics = factory.rare_or_mythic("ori").cards.select{|c| c.rarity == "mythic"}.map(&:name)
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
end

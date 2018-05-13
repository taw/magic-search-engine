describe CardSheet do
  include_context "db"

  # If more than 1 returned, assuming it doesn't matter, and picking first by the usual order
  # (like with basic from same set)
  def physical_card(query, foil=false)
    card_printings = db.search(query).printings
    raise "No card matching #{query.inspect}" if card_printings.empty?
    PhysicalCard.for(card_printings[0], foil)
  end

  let(:m10) { db.sets["m10"] }
  %W[basic common uncommon rare mythic].each do |rarity|
    it "rarity #{rarity}" do
      expected = db.search("e:m10 r:#{rarity}").printings
      actual = CardSheet.rarity(m10, rarity).elements.map(&:main_front)
      expected.should match_array(actual)
    end

    it "cards" do
      sheet = CardSheet.rare_or_mythic(m10)
      sheet.number_of_cards.should eq(15+53)
      expected = db.search("e:m10 r>=rare").printings
      actual = sheet.cards.map(&:main_front)
      expected.should match_array(actual)
    end
  end

  context "#probabilities" do
    context "typical set" do
      let(:rare_or_mythic_sheet) { CardSheet.rare_or_mythic(m10) }
      let(:uncommon_sheet) { CardSheet.rarity(m10, "uncommon") }
      let(:common_sheet) { CardSheet.rarity(m10, "common") }
      let(:basic_sheet) { CardSheet.rarity(m10, "basic") }
      let(:mythic_card) { physical_card("e:m10 baneslayer angel") }
      let(:rare_card) { physical_card("e:m10 birds of paradise") }
      let(:uncommon_card) { physical_card("e:m10 acidic slime") }
      let(:common_card) { physical_card("e:m10 assassinate") }
      let(:basic_card) { physical_card("e:m10 island") }

      it do
        rare_or_mythic_sheet.probabilities[mythic_card].should eq Rational(1, 121)
        rare_or_mythic_sheet.probabilities[rare_card].should eq Rational(2, 121)
        uncommon_sheet.probabilities[uncommon_card].should eq Rational(1, 60)
        common_sheet.probabilities[common_card].should eq Rational(1, 101)
        basic_sheet.probabilities[basic_card].should eq Rational(1, 20)
      end
    end

    context "typical set - foil sheet" do
      let(:foil_sheet) { CardSheet.foil_sheet(m10) }
      let(:mythic_card) { physical_card("e:m10 baneslayer angel", true) }
      let(:rare_card) { physical_card("e:m10 birds of paradise", true) }
      let(:uncommon_card) { physical_card("e:m10 acidic slime", true) }
      let(:common_card) { physical_card("e:m10 assassinate", true) }
      let(:basic_card) { physical_card("e:m10 island", true) }

      it do
        # These are based on some guessing
        foil_sheet.probabilities[mythic_card].should eq Rational(1, 121) * Rational(4,32)
        foil_sheet.probabilities[rare_card].should eq Rational(2, 121) * Rational(4,32)
        foil_sheet.probabilities[uncommon_card].should eq Rational(1, 60) * Rational(8,32)
        foil_sheet.probabilities[common_card].should eq Rational(1, 101) * Rational(16,32)
        foil_sheet.probabilities[basic_card].should eq Rational(1, 20) * Rational(4,32)
      end
    end
  end

  context "Dragon's Maze" do
    let(:rtr) { db.sets["rtr"] }
    let(:gtc) { db.sets["gtc"] }
    let(:dgm) { db.sets["dgm"] }
    let(:land_sheet) { CardSheet.dgm_land_sheet(db) }
    let(:common_sheet) { CardSheet.dgm_common_sheet(db) }
    let(:uncommon_sheet) { CardSheet.rarity(dgm, "uncommon") }
    let(:rare_mythic_sheet) { CardSheet.dgm_rare_mythic_sheet(db) }
    let(:rtr_rare_mythic_sheet) { CardSheet.rare_or_mythic(rtr) }
    let(:gtc_rare_mythic_sheet) { CardSheet.rare_or_mythic(gtc) }

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

    it "Rarities on other sheets (corrected for land sheet and splitc cards)" do
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

  context "Fate Reforged" do
    let(:set) { db.sets["frf"] }
    let(:tapland_subsheet) { }
    let(:fetchland_subsheet) { }

    # TODO: basics are not in boosters
  end

  context "Unhinged" do
    let(:set) { db.sets["uh"] }

    context "rare sheet" do
      let(:rare_sheet) { CardSheet.rare_or_mythic(set) }
      let(:ambiguity) { physical_card("ambiguity", false) }
      let(:super_secret_tech) { physical_card("super secret tech", false) }

      it do
        rare_sheet.probabilities[ambiguity].should eq Rational(1, 40)
        rare_sheet.probabilities[super_secret_tech].should eq 0
      end
    end

    context "foil sheet" do
      let(:unhinged_foil_rares) { CardSheet.unhinged_foil_rares(db) }
      let(:ambiguity) { physical_card("ambiguity", true) }
      let(:super_secret_tech) { physical_card("super secret tech", true) }

      it do
        unhinged_foil_rares.probabilities[ambiguity].should eq Rational(1, 41)
        unhinged_foil_rares.probabilities[super_secret_tech].should eq Rational(1, 41)
      end
    end
  end

  context "Innistrad" do
    let(:set) { db.sets["isd"] }
  end

  context "Dark Ascension" do
    let(:set) { db.sets["dka"] }
  end

  # This even goes to Pack for extra routing test
  context "Masterpieces" do
    let(:pack) { Pack.for(db, set_code) }
    let(:masterpieces) { pack.masterpieces.elements.map(&:main_front) }
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
end

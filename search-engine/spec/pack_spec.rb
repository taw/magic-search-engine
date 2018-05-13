# TODO: WORK IN PROGRESS
describe Pack do
  include_context "db"

  it "Only sets of appropriate types have sealed packs" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      # Indexer responsibility to set this flag
      if set.has_boosters?
        pack = Pack.for(db, set_code)
        if pack
          pack.should be_a(Pack), "#{set_pp} should have packs"
        else
          # TODO: pending
        end
      else
        pack.should eq(nil), "#{set_pp} should not have packs"
      end
    end
  end

  # There's no way this is accurate, we're just approximating foils
  it "Every set with foils has all cards available as foils" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = Pack.for(db, set_code)
      next unless pack
      next unless pack.has_random_foil or pack.has_guaranteed_foil
      pack.sheet(:foil).cards.should match_array(set.physical_cards_in_boosters(true))
        "All cards in #{set_pp} should be possible in its packs as foil"
    end
  end

  context "flip cards" do
    it "Champions of Kamigawa" do
      pack = Pack.for(db, "chk")
      pack.number_of_cards_on_nonfoil_sheets.should eq(88+89+110+20)
      pack.sheet(:rare_or_mythic).number_of_cards.should eq(88)
      # TODO: Brothers Yamazaki alt art
      pack.sheet(:uncommon).number_of_cards.should eq(88+1)
      pack.sheet(:common).number_of_cards.should eq(110)
      pack.sheet(:basic).number_of_cards.should eq(20)
    end

    it "Betrayers of Kamigawa" do
      pack = Pack.for(db, "bok")
      pack.number_of_cards_on_nonfoil_sheets.should eq(55+55+55)
      pack.sheet(:rare_or_mythic).number_of_cards.should eq(55)
      pack.sheet(:uncommon).number_of_cards.should eq(55)
      pack.sheet(:common).number_of_cards.should eq(55)
    end

    it "Saviors of Kamigawa" do
      pack = Pack.for(db, "sok")
      pack.number_of_cards_on_nonfoil_sheets.should eq(55+55+55)
      pack.sheet(:rare_or_mythic).number_of_cards.should eq(55)
      pack.sheet(:uncommon).number_of_cards.should eq(55)
      pack.sheet(:common).number_of_cards.should eq(55)
    end
  end

  context "physical cards are properly setup" do
    it "Dissention" do
      pack = Pack.for(db, "di")
      pack.number_of_cards_on_nonfoil_sheets.should eq(60+60+60)
      # 5 rares are split
      pack.sheet(:rare_or_mythic).number_of_cards.should eq(60)
      # 5 rares are split
      pack.sheet(:uncommon).number_of_cards.should eq(60)
      pack.sheet(:common).number_of_cards.should eq(60)
      # split cards setup correctly
      pack.sheet(:uncommon).elements.map(&:name).should include("Trial // Error")
    end
  end

  # TODO: dfc / aftermath / meld cards

  it "Masters Edition 4" do
    pack = Pack.for(db, "me4")
    basics = pack.sheet(:basic).cards.map(&:name).uniq
    basics.should match_array(["Urza's Mine", "Urza's Power Plant", "Urza's Tower"])
  end

  it "Origins" do
    pack = Pack.for(db, "ori")
    mythics = pack.sheet(:rare_or_mythic).cards.select{|c| c.rarity == "mythic"}.map(&:name)
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

  it "Every card can appear in a pack" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = Pack.for(db, set_code)
      next unless pack
      pack.cards_on_nonfoil_sheets.should match_array(set.physical_cards_in_boosters),
        "All cards in #{set_pp} should be possible in its packs as nonfoil"
    end
  end
end

describe PhysicalCard do
  include_context "db"

  def find_unique(query)
    printings = db.search("++ #{query}").printings
    raise "Expected 1 result for #{query.inspect}, got #{printings.size}" unless printings.size
    printings[0]
  end

  it "all sets can return list of physical cards" do
    db.sets.each do |set_code, set|
      # Need to .uniq as meld appears twice on the left side and once on the right side
      # Also because of foils
      [*set.physical_cards(true), *set.physical_cards(false)]
        .flat_map{|c| [*c.front, *c.back]}
        .uniq
        .should match_array(set.printings)
    end
  end

  let(:physical_card1) { PhysicalCard.for(card1, false) }
  let(:physical_card2) { PhysicalCard.for(card2, false) }
  let(:physical_card3) { PhysicalCard.for(card3, false) }

  context "for normal cards it's just one front" do
    let(:card1) { find_unique("lightning bolt e:m10") }
    it do
      physical_card1.front.should eq([card1])
      physical_card1.back.should eq([])
      physical_card1.foil.should eq(false)
    end
  end

  context "split" do
    let(:card1) { find_unique("crime e:di") }
    let(:card2) { find_unique("punishment e:di") }
    it do
      physical_card1.should eq(physical_card2)
      physical_card1.front.should eq([card1, card2])
      physical_card1.back.should eq([])
      physical_card1.foil.should eq(false)
    end
  end

  context "fuse" do
    let(:card1) { find_unique("alive e:dgm") }
    let(:card2) { find_unique("well e:dgm") }
    it do
      physical_card1.should eq(physical_card2)
      physical_card1.front.should eq([card1, card2])
      physical_card1.back.should eq([])
      physical_card1.foil.should eq(false)
    end
  end

  context "flip" do
    let(:card1) { find_unique("budoka pupil e:bok") }
    let(:card2) { find_unique("ichiga e:bok") }
    it do
      physical_card1.should eq(physical_card2)
      physical_card1.front.should eq([card1, card2])
      physical_card1.back.should eq([])
      physical_card1.foil.should eq(false)
    end
  end

  context "aftermath" do
    let(:card1) { find_unique("appeal e:hou") }
    let(:card2) { find_unique("authority e:hou") }
    it do
      physical_card1.should eq(physical_card2)
      physical_card1.front.should eq([card1, card2])
      physical_card1.back.should eq([])
      physical_card1.foil.should eq(false)
    end
  end

  context "adventure" do
    let(:card1) { find_unique("beanstack giant e:eld") }
    let(:card2) { find_unique("fertile footsteps e:eld") }
    it do
      physical_card1.should eq(physical_card2)
      physical_card1.front.should eq([card1, card2])
      physical_card1.back.should eq([])
      physical_card1.foil.should eq(false)
    end
  end

  context "DFC" do
    let(:card1) { find_unique("delver of secrets e:isd") }
    let(:card2) { find_unique("isnsectile aberration e:isd") }
    it do
      physical_card1.should eq(physical_card2)
      physical_card1.front.should eq([card1])
      physical_card1.back.should eq([card2])
      physical_card1.foil.should eq(false)
    end
  end

  # This doesn't quite fit the model, so just doing our best. The melded card is
  # on both physical cards' backs, and belongs to the one whose back is its top
  # half - Gisela's here.
  context "meld" do
    let(:card1) { find_unique("bruna e:emn") }
    let(:card2) { find_unique("gisela e:emn") }
    let(:card3) { find_unique("brisela e:emn") }
    it do
      physical_card1.should_not eq(physical_card2)
      physical_card2.should eq(physical_card3)

      physical_card1.front.should eq([card1])
      physical_card1.back.should eq([card3])
      physical_card1.foil.should eq(false)

      physical_card2.front.should eq([card2])
      physical_card2.back.should eq([card3])
      physical_card2.foil.should eq(false)
    end

    # Which half is on top is not in mtgjson, it is hardcoded in PatchMeld, so
    # check every pair rather than trusting the one above to be representative.
    it "melded card belongs to the physical card whose back is its top half" do
      {
        "brisela e:emn" => "gisela e:emn",
        "chittering host e:emn" => "graf rats e:emn",
        "hanweir, the writhing township e:emn" => "hanweir battlements e:emn",
        "mishra, lost to phyrexia e:bro" => "mishra, claimed by gix e:bro",
        "titania, gaea incarnate e:bro" => "titania, voice of gaea e:bro",
        "urza, planeswalker e:bro" => "urza, lord protector e:bro",
        "ragnarok, divine deliverance e:fin number:99b" => "vanille, cheerful l'cie e:fin number:211",
      }.each do |melded, top|
        PhysicalCard.for(find_unique(melded)).should eq(PhysicalCard.for(find_unique(top)))
      end
    end
  end

  # We number every face separately, Gatherer style, but some exports want
  # Scryfall style numbers, with one number for the whole physical card
  context "physical_card_number" do
    def physical_card_number(query)
      PhysicalCard.for(find_unique(query), false).physical_card_number
    end

    it "single faced cards keep their number" do
      physical_card_number("lightning bolt e:m10").should eq("146")
      physical_card_number("void beckoner e:iko number:373a").should eq("373a")
    end

    it "multipart cards drop the face letter" do
      physical_card_number("crime e:di").should eq("150")
      physical_card_number("punishment e:di").should eq("150")
      physical_card_number("budoka pupil e:bok").should eq("122")
      physical_card_number("appeal e:hou").should eq("152")
      physical_card_number("beanstalk giant e:eld number:149a").should eq("149")
      physical_card_number("delver of secrets e:isd").should eq("51")
      physical_card_number("insectile aberration e:isd").should eq("51")
    end

    it "meld cards use the number of the front they are part of" do
      physical_card_number("bruna e:emn").should eq("15")
      physical_card_number("gisela e:emn").should eq("28")
      # This one is only ever half of a back, and belongs to Gisela's physical
      # card, so it takes Gisela's number rather than the 15 of mtgjson's 15b
      physical_card_number("brisela e:emn").should eq("28")
      # Prerelease promos have a suffix which is not a face letter
      physical_card_number("bruna e:pemn").should eq("15s")
    end

    it "reversible cards are one physical card in Scryfall numbering" do
      physical_card_number("blightsteel colossus e:sld number:1079a").should eq("1079")
      physical_card_number("blightsteel colossus e:sld number:1079b").should eq("1079")
    end
  end
end

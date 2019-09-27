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

  # This doesn't quite fit the model, so just doing our best
  context "meld" do
    let(:card1) { find_unique("bruna e:emn") }
    let(:card2) { find_unique("gisela e:emn") }
    let(:card3) { find_unique("brisela e:emn") }
    it do
      physical_card1.should_not eq(physical_card2)
      physical_card1.should eq(physical_card3)

      physical_card1.front.should eq([card1])
      physical_card1.back.should eq([card3])
      physical_card1.foil.should eq(false)

      physical_card2.front.should eq([card2])
      physical_card2.back.should eq([card3])
      physical_card2.foil.should eq(false)
    end
  end
end

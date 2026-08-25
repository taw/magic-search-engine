describe "CardDatabase#availability" do
  include_context "db"

  # [kind, name, finish label] for each source, which is what the card page shows
  def availability(id)
    set_code, number = id.split("/")
    printing = db.sets[set_code].printings.find{|p| p.number == number} or raise "No such printing: #{id}"
    db.availability(printing).map do |entry|
      kind = if entry.deck? then :deck elsif entry.booster? then :booster else :product end
      [kind, entry.source.name, entry.finish_label]
    end
  end

  it "decks, with the finish they use" do
    # Every deck this card is in, in every zone. The redemption decks are the
    # same list twice, once nonfoil and once foil.
    availability("som/81").should match_array([
      [:deck, "Relic Breaker", nil],
      [:deck, "Mirromancy", nil],
      [:deck, "Red Deck A", nil],
      [:deck, "Gleeful Flames", nil],
      [:deck, "Sweet Revenge", nil],
      [:deck, "Scars of Mirrodin Redemption", nil],
      [:deck, "Scars of Mirrodin Foil Redemption", "foil"],
      [:booster, "Scars of Mirrodin Draft Booster", "nonfoil and foil"],
      [:booster, "Scars of Mirrodin Six-card Booster Pack", nil],
    ])
  end

  # Four printings of one card in one set, all four in the same two decks
  it "several printings of one card in one set" do
    %W[339 340 341 342].each do |number|
      availability("c15/#{number}").should match_array([
        [:deck, "Plunder the Graves", nil],
        [:deck, "Swell the Host", nil],
      ])
    end
  end

  it "boosters, with every finish they can produce" do
    availability("znr/1").should match_array([
      [:deck, "Zendikar Rising Redemption", nil],
      [:deck, "Zendikar Rising Foil Redemption", "foil"],
      [:booster, "Zendikar Rising Draft Booster", "nonfoil and foil"],
      [:booster, "Zendikar Rising Set Booster", "nonfoil and foil"],
      [:booster, "Zendikar Rising Collector Booster", "foil"],
      [:booster, "Zendikar Rising Arena Booster", nil],
      [:booster, "Zendikar Rising Theme Booster White", nil],
      [:booster, "Zendikar Rising Theme Booster Party", nil],
    ])
  end

  it "etched is its own finish, not foil" do
    availability("2x2/413").should eq([
      [:booster, "Double Masters 2022 Collector Booster", "etched"],
    ])
  end

  # The 376 card/finish rows nothing else can reach - a Secret Lair or a bundle
  # promo is in no deck and on no sheet, only in one product's own contents
  it "products which name the card themselves" do
    availability("blb/386").should eq([
      [:product, "Bloomburrow Bundle", "foil"],
    ])
  end

  # Booster boxes, cases and displays reach every card in the set through their
  # subproducts, and none of them belong on a card page
  it "products which only contain the card through a pack, deck or subproduct" do
    availability("znr/1").none?{|kind, _, _| kind == :product }.should eq(true)
  end

  it "a back face has the same availability as the card it is a face of" do
    db.availability(db.sets["mid"].printings.find{|p| p.number == "246b"})
      .should eq(db.availability(db.sets["mid"].printings.find{|p| p.number == "246a"}))
  end

  it "cards in nothing at all" do
    # A promo handed out on its own is in no deck, booster or product
    availability("pdrc/1").should eq([])
  end
end

describe "CardDatabase#availability_of_all_printings" do
  include_context "db"

  # The batch form exists because calling availability once per printing
  # rescans the decks and the booster sheets every time, which is 400ms on a
  # basic land. It has to answer exactly what that loop answers.
  def same_as_per_printing(card_name)
    card = db.cards.each_value.find{|c| c.name == card_name} or raise "No such card: #{card_name}"
    batch = db.availability_of_all_printings(card)
    batch.keys.should eq(card.printings)
    card.printings.each do |printing|
      batch[printing].should eq(db.availability(printing))
    end
    batch
  end

  it "one printing" do
    same_as_per_printing("A Display of My Dark Power")
  end

  it "a card in decks, boosters and products at once" do
    same_as_per_printing("Ajani, Mentor of Heroes")
  end

  # The case the batch form is for. One deck or one sheet can reach several
  # printings here, which the per-printing scan never sees.
  it "a basic land" do
    batch = same_as_per_printing("Forest")
    batch.size.should be > 500
    batch.values.any?{|availability| availability.size > 2}.should eq(true)
  end

  it "a card in nothing at all" do
    batch = same_as_per_printing("1996 World Champion")
    batch.values.flatten.should eq([])
  end
end

describe CardAvailability do
  def label(*finishes)
    CardAvailability.new(nil, finishes).finish_label
  end

  it "labels nothing when the card is just a card" do
    label(:nonfoil).should eq(nil)
  end

  it "labels a single premium finish" do
    label(:foil).should eq("foil")
    label(:etched).should eq("etched")
  end

  it "names the nonfoil finish too once there is more than one" do
    label(:nonfoil, :foil).should eq("nonfoil and foil")
    label(:nonfoil, :foil, :etched).should eq("nonfoil, foil, and etched")
    label(:foil, :etched).should eq("foil and etched")
  end

  it "normalizes order and duplicates" do
    # A booster with a foil sheet and an etched sheet reaches the card twice
    label(:etched, :foil, :etched).should eq("foil and etched")
  end
end

describe "is:productless" do
  include_context "db"

  def productless(query)
    db.search("is:productless #{query}").printings.map{|printing| "#{printing.set_code}/#{printing.number}" }
  end

  def printings(query)
    db.search(query).printings.map{|printing| "#{printing.set_code}/#{printing.number}" }
  end

  it "printings nothing in the database can be got from" do
    # A promo handed out on its own, the same one CardDatabase#availability
    # returns an empty list for
    productless("e:pdrc").should eq(["pdrc/1"])
  end

  it "not printings a deck, a booster or a product has" do
    "is:productless e:som".should return_no_cards
  end

  # These are the whole reason it is not "is:boosterless" - a card that only
  # ever came in one premium finish is still a card you can get
  it "any finish counts, not just nonfoil" do
    printings("e:2x2 number:413").should eq(["2x2/413"]) # collector booster, etched only
    printings("e:blb number:386").should eq(["blb/386"]) # bundle promo, foil only
    "is:productless (e:2x2 number:413 or e:blb number:386)".should return_no_cards
  end

  # Availability is a property of the physical card, so a back face has to
  # answer the same as the front it is printed on
  it "faces of one physical card are productless together" do
    results = db.search("is:productless").printings.to_set
    db.search("is:back").printings.each do |back|
      [back.name, results.include?(back)].should eq([back.name, results.include?(back.main_front)])
    end
  end

  # The reason for the separate scan is speed, not a different question, so it
  # has to agree with what the card page shows, printing by printing
  it "is exactly the printings CardDatabase#availability finds nothing for" do
    expected = db.sets["znr"].printings.select{|printing| db.availability(printing).empty? }
    db.search("is:productless e:znr").printings.should match_array(expected)
    expected.should_not be_empty
  end

  it "judge gift promos are in no product at all" do
    # Handed out on their own, so most of the set is genuinely productless -
    # only the few reprinted into something else are not
    productless("promo:judgegift").size.should be > 100
  end
end

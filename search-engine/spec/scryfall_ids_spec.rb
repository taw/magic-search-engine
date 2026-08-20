describe ScryfallIds do
  include_context "db"

  # Old sets, whose ids are not going to be revisited by a data update
  def printing(name, set_code, number)
    card = db.cards[name] or raise "No such card: #{name}"
    found = card.printings.find{|printing| printing.set_code == set_code and printing.number == number }
    found&.physical_card or raise "No such printing: #{name} [#{set_code}:#{number}]"
  end

  let(:ancestors_chosen) { printing("ancestor's chosen", "10e", "1") }
  let(:delver) { printing("delver of secrets", "isd", "51a") }
  let(:aberration) { printing("insectile aberration", "isd", "51b") }
  let(:fire) { printing("fire", "apc", "128a") }

  it "finds the id of a printing" do
    ScryfallIds.lookup([ancestors_chosen]).should eq(
      ancestors_chosen => "7a5cd03c-4227-4551-aa4b-7d119f0468b5",
    )
  end

  # We number faces, Scryfall numbers physical cards, so both of our numbers
  # carry the one id
  it "gives both faces of a card the same id" do
    ids = ScryfallIds.lookup([delver, aberration])
    ids[delver].should eq("11bf83bb-c95b-4b4f-9a56-ce7a1816307a")
    ids[aberration].should eq(ids[delver])
  end

  it "answers for both finishes of a printing" do
    foil = PhysicalCard.for(fire.main_front, finish: :foil)
    ScryfallIds.lookup([fire, foil]).should eq(
      fire => "f98f4538-5b5b-475d-b98f-49d01dae6f04",
      foil => "f98f4538-5b5b-475d-b98f-49d01dae6f04",
    )
  end

  it "answers about nothing at all" do
    ScryfallIds.lookup([]).should eq({})
  end

  # Which is what lets the Cockatrice export always write a uuid
  it "has an id for every printing we have" do
    rows = ScryfallIds::PATH.readlines.map{|line| line.chomp.split("\t") }
    rows.map(&:size).uniq.should eq([4])
    known = rows.map{|set_code, number, _, _| [set_code, number] }.to_set
    db.printings.reject{|printing| known.include?([printing.set_code, printing.number]) }.should eq([])
  end
end

describe MtgoIds do
  include_context "db"

  # Old sets only. Their MTGO ids were assigned once, a long time ago, and
  # unlike a card's printings they do not get revisited by later data updates.
  def printing(name, set_code, number)
    card = db.cards[name] or raise "No such card: #{name}"
    found = card.printings.find{|printing| printing.set_code == set_code and printing.number == number }
    found&.physical_card or raise "No such printing: #{name} [#{set_code}:#{number}]"
  end

  let(:ancestors_chosen) { printing("ancestor's chosen", "10e", "1") }
  let(:portal_plains) { printing("plains", "por", "196") }
  let(:portal_blaze) { printing("blaze", "por", "118") }
  let(:seventh_blaze) { printing("blaze", "7ed", "175") }
  # Fifth Edition never made it to MTGO, and this one was never reprinted
  let(:zephyr_falcon) { printing("zephyr falcon", "5ed", "137") }

  it "finds the id of a printing MTGO has" do
    MtgoIds.lookup([ancestors_chosen, portal_plains]).should eq(
      ancestors_chosen => "27500",
      portal_plains => "9123",
    )
  end

  it "falls back to the card's first appearance on MTGO" do
    # Portal is not on MTGO, but Blaze is, and MTGO does not care which
    # printing of it you mean
    MtgoIds.lookup([portal_blaze]).should eq(portal_blaze => "15382")
    MtgoIds.lookup([seventh_blaze]).should eq(seventh_blaze => "15382")
  end

  it "prefers the printing it was asked about" do
    tenth_blaze = printing("blaze", "10e", "190")
    MtgoIds.lookup([tenth_blaze]).should eq(tenth_blaze => "27388")
  end

  it "leaves out a card MTGO does not have" do
    MtgoIds.lookup([zephyr_falcon, ancestors_chosen]).should eq(ancestors_chosen => "27500")
  end

  it "answers about many cards in one pass, and about nothing at all" do
    cards = [ancestors_chosen, portal_plains, portal_blaze, zephyr_falcon]
    MtgoIds.lookup(cards).keys.should match_array([ancestors_chosen, portal_plains, portal_blaze])
    MtgoIds.lookup([]).should eq({})
  end

  it "gives a foil card the normal id, as MTGO's premium ids are not indexed" do
    foil = PhysicalCard.for(ancestors_chosen.main_front, finish: :foil)
    MtgoIds.lookup([foil]).should eq(foil => "27500")
    # Two cards here, one printing in the file, and the name fallback must not
    # answer for either of them
    MtgoIds.lookup([foil, ancestors_chosen]).should eq(
      foil => "27500",
      ancestors_chosen => "27500",
    )
  end

  describe "the file it reads" do
    let(:rows) { MtgoIds::PATH.readlines.map{|line| line.chomp.split("\t") } }

    it "is set code, our own collector number, id, and name" do
      rows.reject{|row| row.size == 4 }.should eq([])
      rows.reject{|row| row[2] =~ /\A\d+\z/ }.should eq([])
    end

    it "has one row per printing" do
      keys = rows.map{|set_code, number, _, _| [set_code, number] }
      keys.size.should eq(keys.uniq.size)
    end

    it "only names printings MTGO has" do
      printings = db.printings.to_h{|printing| [[printing.set_code, printing.number], printing] }
      rows.reject{|set_code, number, _, _| printings[[set_code, number]]&.mtgo? }.should eq([])
    end

    it "covers the sets which are on MTGO" do
      set_codes = rows.map(&:first).uniq
      set_codes.should include("10e", "7ed", "mmq", "inv", "ody")
      set_codes.should_not include("ced", "cei")
    end

    # These sets exist nowhere but MTGO, so every printing of theirs that MTGO
    # has is a printing MTGO released, and an id it must know. A gap here is a
    # printing our matching failed to place, not a card MTGO skipped.
    # (`online_only?` is no help picking them out - it is true of the Arena
    # sets too, and of Astral Cards and the Sega Dreamcast cards.)
    MTGO_ONLY_SETS = %w[
      pmoa me1 me2 me3 td0 me4 td2 vma tpr pz1 pz2 prm om1 omb
    ]

    it "has an id for every printing in the MTGO-only sets" do
      keys = rows.map{|set_code, number, _, _| [set_code, number] }.to_set
      missing = MTGO_ONLY_SETS.flat_map do |set_code|
        set = db.sets[set_code] or raise "No such set: #{set_code}"
        set.printings.select(&:mtgo?).reject{|printing| keys.include?([printing.set_code, printing.number]) }
      end
      missing.map{|printing| "#{printing.set_code}:#{printing.number} #{printing.name}" }.should eq([])
    end
  end
end

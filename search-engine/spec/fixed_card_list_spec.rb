describe FixedCardList do
  include_context "db", "mrd", "arn"

  let(:list) { FixedCardList.new(db, text) }
  let(:names) { list.cards.map(&:name) }

  describe "one card per line" do
    let(:text) { "mrd:1\narn:1\n" }
    it do
      names.should eq ["Altar's Light", "Abu Ja'far"]
      list.warnings.should eq []
    end
  end

  describe "counts" do
    let(:text) { "3x mrd:1\n2 arn:3\n" }
    it do
      names.should eq ["Altar's Light"] * 3 + ["Camel"] * 2
      list.warnings.should eq []
    end
  end

  describe "slash separator, as the CLI spells it" do
    let(:text) { "2x mrd/2" }
    it do
      names.should eq ["Arrest", "Arrest"]
      list.warnings.should eq []
    end
  end

  describe "case and spacing" do
    let(:text) { "  2 X MRD : 3  " }
    it do
      names.should eq ["Auriok Bladewarden", "Auriok Bladewarden"]
      list.warnings.should eq []
    end
  end

  describe "collector numbers which aren't just digits" do
    let(:text) { "arn:2†" }
    it do
      names.should eq ["Army of Allah"]
      list.cards.map(&:number).should eq ["2†"]
      list.warnings.should eq []
    end
  end

  describe "foil" do
    let(:text) { "mrd:1:foil\nmrd:1\n" }
    it do
      list.cards.map(&:foil).should eq [true, false]
      list.warnings.should eq []
    end
  end

  describe "blank lines are skipped" do
    let(:text) { "\n\nmrd:1\n   \n" }
    it do
      names.should eq ["Altar's Light"]
      list.warnings.should eq []
    end
  end

  describe "no text at all" do
    let(:text) { nil }
    it do
      list.cards.should eq []
      list.warnings.should eq []
    end
  end

  # The box is hand-edited, so one bad line must not cost the player the rest
  describe "bad lines are reported, good ones still open" do
    let(:text) { "mrd:1\nwhatever\nlolwtf:1\nmrd:9999\narn:3\n" }
    it do
      names.should eq ["Altar's Light", "Camel"]
      list.warnings.should eq [
        "Invalid line: whatever",
        "Cannot find set with code: lolwtf for line: lolwtf:1",
        "Cannot find card set with number 9999 in set mrd for line: mrd:9999",
      ]
    end
  end

  describe ".line_for" do
    let(:card) { physical_card("e:mrd number:1") }
    let(:foil_card) { physical_card("e:mrd number:1", true) }

    it "round-trips through the parser" do
      FixedCardList.line_for(card).should eq "1x mrd:1"
      FixedCardList.line_for(foil_card).should eq "1x mrd:1:foil"
      FixedCardList.new(db, FixedCardList.line_for(card)).cards.should eq [card]
      FixedCardList.new(db, FixedCardList.line_for(foil_card)).cards.should eq [foil_card]
    end
  end
end

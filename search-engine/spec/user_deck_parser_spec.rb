describe UserDeckParser do
  let(:path) { Pathname("#{__dir__}/decklists/#{filename}") }
  let(:content) { path.read }
  let(:parser) { UserDeckParser.new(content) }

  describe "empty" do
    let(:filename) { "empty.txt" }
    it do
      parser.should be_valid
      parser.deck.should eq ""
    end
  end

  describe "utf8" do
    let(:filename) { "utf8.txt" }
    it do
      parser.should be_valid
      parser.deck.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "utf8 bom" do
    let(:filename) { "utf8_bom.txt" }
    it do
      parser.should be_valid
      parser.deck.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "\\r line endings" do
    let(:filename) { "cr.txt" }
    it do
      parser.should be_valid
      parser.deck.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "\\n\\r line endings" do
    let(:filename) { "crlf.txt" }
    it do
      parser.should be_valid
      parser.deck.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "windows encoding" do
    let(:filename) { "windows.txt" }
    it do
      parser.should be_valid
      parser.deck.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end
end

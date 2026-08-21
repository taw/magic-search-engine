describe UserDeckPreprocessor do
  let(:path) { Pathname("#{__dir__}/decklists/#{filename}") }
  let(:content) { path.read }
  let(:preprocessor) { UserDeckPreprocessor.new(content) }

  describe "empty" do
    let(:filename) { "empty.txt" }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq ""
    end
  end

  describe "utf8" do
    let(:filename) { "utf8.txt" }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "utf8 bom" do
    let(:filename) { "utf8_bom.txt" }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "\\r line endings" do
    let(:filename) { "cr.txt" }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "\\n\\r line endings" do
    let(:filename) { "crlf.txt" }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  describe "windows encoding" do
    let(:filename) { "windows.txt" }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(
        "30x Lightning Bolt\n"+
        "20x Dandân\n"+
        "10x Mountain\n"
      )
    end
  end

  # Two blocks, but the second one is the deck, not a sideboard
  describe "arena .txt" do
    let(:filename) { "arena.txt" }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(path.read)
    end
  end

  describe "cockatrice .cod xml" do
    let(:filename) { "knights.cod" }
    let(:output) { Pathname("#{__dir__}/decklists/knights.out").read }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(output)
    end
  end

  # Cockatrice writes the printing on every card, and so do we
  describe "cockatrice .cod xml with printings" do
    let(:filename) { "printings.cod" }
    let(:output) { Pathname("#{__dir__}/decklists/printings.out").read }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(output)
    end
  end

  describe "mtgo .dek xml" do
    let(:filename) { "allies.dek" }
    let(:output) { Pathname("#{__dir__}/decklists/allies.out").read }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(output)
    end
  end

  describe "old xmage .dck" do
    let(:filename) { "free_win_red.dck" }
    let(:output) { Pathname("#{__dir__}/decklists/free_win_red.dck").read.delete("\r") }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(output)
    end
  end

  describe "humans xmage .dck" do
    let(:filename) { "humans.dck" }
    let(:output) { Pathname("#{__dir__}/decklists/humans.out").read }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(output)
    end
  end

  describe "mtgo .txt" do
    let(:filename) { "allies2.txt" }
    let(:output) { Pathname("#{__dir__}/decklists/allies2.out").read }
    it do
      preprocessor.should be_valid
      preprocessor.text.should eq(output)
    end
  end
end

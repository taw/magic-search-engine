describe "Spelling" do
  include_context "db"

  def spelling_suggestions(word)
    db.suggest_spelling(word)
  end

  it "spelling" do
    spelling_suggestions("kolagan").should eq(["kolaghan"])
    # if distance 1 match, only display that, not distance 2
    spelling_suggestions("SHANDRA").should eq(["chandra"])
    # if not, display all distance 2 matches
    spelling_suggestions("SHANDRAA").should eq([ "chandra", "shandlar" ])
    spelling_suggestions("Ajuni").should eq([ "ajani" ])
    spelling_suggestions("Ætherise").should eq([ "aetherize" ])
    spelling_suggestions("ajuni's").should eq([ "ajani" ])
    # stemming and spelling interaction
    spelling_suggestions("pyrokynesis").should eq([ "pyrokinesis" ])
  end

  it "spelling_search" do
    "kolagan".should return_cards(
      "Dragonlord Kolaghan",
      "Kolaghan Aspirant",
      "Kolaghan Forerunners",
      "Kolaghan Monument",
      "Kolaghan Skirmisher",
      "Kolaghan Stormsinger",
      "Kolaghan's Command",
      "Kolaghan, the Storm's Fury",
    )
    "pyrokynesis".should return_cards(
      "Pyrokinesis",
    )
  end

  it "spelling_short_words" do
    # 1-2 letters - 0 corrections
    spelling_suggestions("7").should eq([])
    spelling_suggestions("77").should eq([])
    # 3-4 letters - 1 correction
    spelling_suggestions("mux").should eq(["lux", "mox", "mul"])
    spelling_suggestions("xxx").should eq([])
    # size applied after unicode normalization
    spelling_suggestions("aethr").should eq(["aether"])
    spelling_suggestions("æthr").should eq(["aether"])
  end
end

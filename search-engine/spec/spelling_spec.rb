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
    # two words
    spelling_suggestions("gutshot").should eq([ "gut shot" ])
    # do not match "dark more" just because they are words
    spelling_suggestions("darkmore").should eq([ "dakmor" ])
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
    spelling_suggestions("mux").should eq(["lux", "mox", "mu", "mul"])
    spelling_suggestions("xxx").should eq([])
    # size applied after unicode normalization
    spelling_suggestions("aethr").should eq(["aether"])
    spelling_suggestions("æthr").should eq(["aether"])
  end

  it "accidentally spelled together" do
    "Jace the Mindsculptor".should return_cards("Jace, the Mind Sculptor")
    "Gutshot".should return_cards("Gut Shot")
    "Firstwing".should return_cards("Azorius First-Wing")
    "First Wing".should return_cards("Azorius First-Wing")
    "First-Wing".should return_cards("Azorius First-Wing")
    '"Firstwing"'.should return_cards("Azorius First-Wing")
    '"First Wing"'.should return_cards("Azorius First-Wing")
    '"First-Wing"'.should return_cards("Azorius First-Wing")
  end

  it "every card with hyphen can be searched as one or two words" do
    cards_with_hyphens = db.cards.values.select{|c| c.name =~ /-/}.map(&:name)
    cards_with_hyphens.each_with_index do |name, i|
      # Ignore 3+ part names
      next if name =~ /-\S+-/
      # Both "Flame-Kin" and "Flamekin" spellings are used, so we skip that one
      next if name =~ /Flame-Kin|Death-Mask|Great-Horn|Wild-Field/i
      # Card names including other card names messes up with this test
      next if name == "Greven il-Vec"
      next if name == "Ink-Eyes, Servant of Oni"
      next if name == "Two-Headed Giant"
      next if name == "Two-Headed Giant of Foriys"
      next if name == "Ur-Drago"
      next if name == "The Ur-Dragon"
      next if name == "Palladia-Mors"
      next if name == "Armored Wolf-Rider"
      # Too complex
      next if name == "Death's-Head Buzzard"
      # I don't even
      next if name == "Guan Yu's 1,000-Li March"
      # Ignore Unstable augments
      next if name == "Monkey-"
      next if name == "Rhino-"
      next if name == "Robo-"
      next if name == "Bat-"

      name.should return_cards(name)
      name.gsub("-", "").should return_cards(name)
      name.gsub("-", " ").should include_cards(name)
    end
  end
end

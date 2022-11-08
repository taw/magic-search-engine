describe "Shadowmoor" do
  include_context "db"

  it "is:reprint" do
    "e:c16 is:reprint t:legendary".should return_cards(
      "Alesha, Who Smiles at Death",
      "Daretti, Scrap Savant",
      "Edric, Spymaster of Trest",
      "Ghave, Guru of Spores",
      "Godo, Bandit Warlord",
      "Gwafa Hazid, Profiteer",
      "Hanna, Ship's Navigator",
      "Iroas, God of Victory",
      "Jor Kadeen, the Prevailer",
      "Kazuul, Tyrant of the Cliffs",
      "Nath of the Gilt-Leaf",
      "Selvala, Explorer Returned",
      "Sharuum the Hegemon",
      "Slobad, Goblin Tinkerer",
      "Sydri, Galvanic Genius",
      "Vorel of the Hull Clade",
      "Zedruu the Greathearted",
    )
  end

  it "not:reprint" do
    "e:c16 not:reprint t:legendary".should return_cards(
      "Akiri, Line-Slinger",
      "Atraxa, Praetors' Voice",
      "Breya, Etherium Shaper",
      "Bruse Tarl, Boorish Herder",
      "Ikra Shidiqi, the Usurper",
      "Ishai, Ojutai Dragonspeaker",
      "Kraum, Ludevic's Opus",
      "Kydele, Chosen of Kruphix",
      "Kynaios and Tiro of Meletis",
      "Ludevic, Necro-Alchemist",
      "Ravos, Soultender",
      "Reyhan, Last of the Abzan",
      "Saskia the Unyielding",
      "Sidar Kondo of Jamuraa",
      "Silas Renn, Seeker Adept",
      "Tana, the Bloodsower",
      "Thrasios, Triton Hero",
      "Tymna the Weaver",
      "Vial Smasher the Fierce",
      "Yidris, Maelstrom Wielder",
    )
  end

  it "sanity check" do
    "e:alpha not:reprint".should equal_search("e:alpha")
    "e:beta not:reprint".should return_cards(
      "Circle of Protection: Black",
      "Volcanic Island",
    )
  end
end

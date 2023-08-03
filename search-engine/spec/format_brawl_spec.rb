describe "Formats - Brawl" do
  include_context "db"

  it do
    assert_block_composition "brawl", Date.parse("2018-05-11"), ["kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom"],
      "Smuggler's Copter" => "banned",
      "Baral, Chief of Compliance" => "banned",
      "Sorcerous Spyglass" => "banned"
  end

  it do
    assert_block_composition "brawl", "dom", ["kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom"],
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned",
      "Attune with Aether" => "banned",
      "Rogue Refiner" => "banned",
      "Rampaging Ferocidon" => "banned",
      "Ramunap Ruins" => "banned"
  end

  it do
    assert_block_composition "brawl", "ltr", ["mid", "vow", "neo", "snc", "dmu", "bro", "one", "mom", "mat"],
      "Pithing Needle" => "banned",
      # They're now permanently legal ignoring rotation, but they weren't originally
      "Arcane Signet" => "legal",
      "Command Tower" => "legal"
  end

  it "brawl extra cards" do
    assert_legality "brawl", Date.parse("2023-08-01"), "Arcane Signet", "legal"
    assert_legality "brawl", Date.parse("2023-08-01"), "Command Tower", "legal"
  end
end

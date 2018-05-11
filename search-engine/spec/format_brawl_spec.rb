describe "Formats - Brawl" do
  include_context "db"

  it do
    assert_block_composition "brawl", Date.parse("2018-05-11"), ["kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom"],
      "Smuggler's Copter" => "banned",
      "Baral, Chief of Compliance" => "banned",
      "Sorcerous Spyglass" => "banned"
    assert_block_composition "brawl", "dom", ["kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom"],
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned",
      "Attune with Aether" => "banned",
      "Rogue Refiner" => "banned",
      "Rampaging Ferocidon" => "banned",
      "Ramunap Ruins" => "banned"
  end
end

describe "Formats - Block Constructed" do
  include_context "db"

  # After a while WotC abandoned block constructed, so we're making things up here
  describe "Block legal sets" do
    let(:start_date) { db.sets["ia"].release_date }
    let(:end_date) { db.sets["rix"].release_date }
    let(:block_formats) { Format.formats_index.select{|k,v| k =~ /block\z/}.values.uniq }
    let(:expansion_sets) { db.sets.values.select{|s| s.type == "expansion" } }
    let(:expected) { expansion_sets.select{|s| s.release_date >= start_date and s.release_date <= end_date and s.code != "hl" }.map(&:code).to_set }
    let(:actual) { block_formats.map{|f| f.new.included_sets.to_a }.flatten.to_set }
    it do
      expected.should eq actual
    end
  end

  describe "Un legal sets" do
    let(:unsets) { db.sets.values.select{|s| s.type == "un" } }
    let(:expected) { unsets.map(&:code).to_set }
    let(:actual) { FormatUnsets.new.included_sets }
    it do
      expected.should eq actual
    end
  end

  ## Individual Block Constructed Formats

  it "ice_age" do
    assert_block_composition "ice age block", "ia", ["ia"],
      "Amulet of Quoz" => "banned"
    assert_block_composition "ice age block", "ai", ["ia", "ai"],
      "Amulet of Quoz" => "banned"
    assert_block_composition "ice age block", "cs", ["ia", "ai", "cs"],
      "Thawing Glaciers" => "banned",
      "Zuran Orb" => "banned",
      "Amulet of Quoz" => "banned"
  end

  it "mirage" do
    assert_block_composition_sequence "mirage block", "mr", "vi", "wl"
  end

  it "tempest" do
    # No idea when Cursed Scroll was banned exactly
    assert_block_composition "tempest block", "tp", ["tp"],
      "Cursed Scroll" => "banned"
    assert_block_composition "tempest block", "sh", ["tp", "sh"],
      "Cursed Scroll" => "banned"
    assert_block_composition "tempest block", "ex", ["tp", "sh", "ex"],
      "Cursed Scroll" => "banned"
  end

  it "urza" do
    assert_block_composition "urza block", "us", ["us"]
    assert_block_composition "urza block", "ul", ["us", "ul"]
    assert_block_composition "urza block", "ud", ["us", "ul", "ud"],
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Windfall" => "banned"
    assert_block_composition "urza block", nil, ["us", "ul", "ud"],
      "Gaea's Cradle" => "banned",
      "Memory Jar" => "banned",
      "Serra's Sanctum" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Voltaic Key" => "banned",
      "Windfall" => "banned"
  end

  it "masques" do
    assert_block_composition_sequence "masques block", "mm", "ne", "pr"
    assert_block_composition "masques block", nil, ["mm", "ne", "pr"],
      "Lin Sivvi, Defiant Hero" => "banned",
      "Rishadan Port" => "banned"
  end

  it "invasion" do
    assert_block_composition_sequence "invasion block", "in", "ps", "ap"
  end

  it "odyssey" do
    assert_block_composition_sequence "odyssey block", "od", "tr", "ju"
  end

  it "onslaught" do
    assert_block_composition_sequence "onslaught block", "on", "le", "sc"
  end

  it "mirrodin" do
    assert_block_composition_sequence "mirrodin block", "mi", "ds", "5dn"
    assert_block_composition "mirrodin block", nil, ["mi", "ds", "5dn"],
      "Aether Vial" => "banned",
      "Ancient Den" => "banned",
      "Arcbound Ravager" => "banned",
      "Darksteel Citadel" => "banned",
      "Disciple of the Vault" => "banned",
      "Great Furnace" => "banned",
      "Seat of the Synod" => "banned",
      "Skullclamp" => "banned",
      "Tree of Tales" => "banned",
      "Vault of Whispers" => "banned"
  end

  it "time_spiral" do
    # Two sets released simultaneously
    assert_block_composition "time spiral block", "ts", ["ts", "tsts"]
    assert_block_composition "time spiral block", "tsts", ["ts", "tsts"]
    assert_block_composition "time spiral block", "pc", ["ts", "tsts", "pc"]
    assert_block_composition "time spiral block", "fut", ["ts", "tsts", "pc", "fut"]
  end

  it "ravnica" do
    assert_block_composition_sequence "ravnica block", "rav", "gp", "di"
  end

  it "kamigawa" do
    assert_block_composition_sequence "kamigawa block", "chk", "bok", "sok"
  end

  it "lorwyn_shadowmoor" do
    assert_block_composition_sequence "lorwyn shadowmoor block", "lw", "mt", "shm", "eve"
    assert_block_composition_sequence "lorwyn block", "lw", "mt", "shm", "eve"
  end

  it "shards_of_alara" do
    assert_block_composition_sequence "shards of alara block", "ala", "cfx", "arb"
  end

  it "zendikar" do
    assert_block_composition_sequence "zendikar block", "zen", "wwk", "roe"
  end

  it "scars_of_mirrodin" do
    assert_block_composition_sequence "scars of mirrodin block", "som", "mbs", "nph"
  end

  it "innistrad" do
    assert_block_composition "innistrad block", "isd", ["isd"]
    assert_block_composition "innistrad block", "dka", ["isd", "dka"]
    assert_block_composition "innistrad block", "avr", ["isd", "dka", "avr"],
      "Lingering Souls" => "banned",
      "Intangible Virtue" => "banned"

    assert_legality "innistrad block", "isd", "Lingering Souls", nil
    assert_legality "innistrad block", "dka", "Lingering Souls", "legal"
    assert_legality "innistrad block", "avr", "Lingering Souls", "banned"

    assert_legality "innistrad block", "isd", "Intangible Virtue", "legal"
    assert_legality "innistrad block", "dka", "Intangible Virtue", "legal"
    assert_legality "innistrad block", "avr", "Intangible Virtue", "banned"
  end

  it "return to ravnica" do
    assert_block_composition_sequence "return to ravnica block", "rtr", "gtc", "dgm"
  end

  it "theros" do
    assert_block_composition_sequence "theros block", "ths", "bng", "jou"
  end

  it "tarkir" do
    assert_block_composition_sequence "tarkir block", "ktk", "frf", "dtk"
  end

  it "battle for zendikar" do
    assert_block_composition_sequence "battle for zendikar block", "bfz", "ogw"
  end

  it "shadows over innistrad" do
    assert_block_composition_sequence "shadows over innistrad block", "soi", "emn"
  end

  it "amonkhet" do
    assert_block_composition_sequence "amonkhet block", "akh", "hou"
  end

  it "ixalan" do
    assert_block_composition_sequence "ixalan block", "xln", "rix"
  end

  it "unsets" do
    assert_block_composition_sequence "unsets", "ug", "uh", "ust"
  end
end

describe "Formats - Block Constructed" do
  include_context "db"

  # After a while WotC abandoned block constructed, so we're making things up here
  describe "Block legal sets" do
    let(:start_date) { db.sets["ice"].release_date }
    let(:end_date) { db.sets["rix"].release_date }
    let(:block_formats) { Format.formats_index.select{|k,v| k.end_with?('block')}.values.uniq }
    let(:expansion_sets) { db.sets.values.select{|s| s.types.include?("expansion") } }
    let(:expected) { expansion_sets.select{|s| s.release_date >= start_date and s.release_date <= end_date and s.code != "hml" }.map(&:code).to_set }
    let(:actual) { block_formats.map{|f| f.new.included_sets.to_a }.flatten.to_set }
    it do
      expected.should eq actual
    end
  end

  # I don't even know what this means anymore
  describe "Un legal sets" do
    let(:unsets) { db.sets.values.select{|s| s.types.include?("un") } }
    let(:expected) { unsets.map(&:code).to_set - ["unf"] }
    let(:actual) { FormatUnsets.new.included_sets }
    it do
      expected.should eq actual
    end
  end

  ## Individual Block Constructed Formats

  it "ice_age" do
    assert_block_composition "ice age block", "ice", ["ice"],
      "Amulet of Quoz" => "banned"
    assert_block_composition "ice age block", "all", ["ice", "all"],
      "Amulet of Quoz" => "banned"
    assert_block_composition "ice age block", "csp", ["ice", "all", "csp"],
      "Thawing Glaciers" => "banned",
      "Zuran Orb" => "banned",
      "Amulet of Quoz" => "banned"
  end

  it "mirage" do
    assert_block_composition_sequence "mirage block", "mir", "vis", "wth"
  end

  it "tempest" do
    # No idea when Cursed Scroll was banned exactly
    assert_block_composition "tempest block", "tmp", ["tmp"],
      "Cursed Scroll" => "banned"
    assert_block_composition "tempest block", "sth", ["tmp", "sth"],
      "Cursed Scroll" => "banned"
    assert_block_composition "tempest block", "exo", ["tmp", "sth", "exo"],
      "Cursed Scroll" => "banned"
  end

  it "urza" do
    assert_block_composition "urza block", "usg", ["usg"]
    assert_block_composition "urza block", "ulg", ["usg", "ulg"]
    assert_block_composition "urza block", "uds", ["usg", "ulg", "uds"],
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Windfall" => "banned"
    assert_block_composition "urza block", nil, ["usg", "ulg", "uds"],
      "Gaea's Cradle" => "banned",
      "Memory Jar" => "banned",
      "Serra's Sanctum" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Voltaic Key" => "banned",
      "Windfall" => "banned"
  end

  it "masques" do
    assert_block_composition_sequence "masques block", "mmq", "nem", "pcy"
    assert_block_composition "masques block", nil, ["mmq", "nem", "pcy"],
      "Lin Sivvi, Defiant Hero" => "banned",
      "Rishadan Port" => "banned"
  end

  it "invasion" do
    assert_block_composition_sequence "invasion block", "inv", "pls", "apc"
  end

  it "odyssey" do
    assert_block_composition_sequence "odyssey block", "ody", "tor", "jud"
  end

  it "onslaught" do
    assert_block_composition_sequence "onslaught block", "ons", "lgn", "scg"
  end

  it "mirrodin" do
    assert_block_composition_sequence "mirrodin block", "mrd", "dst", "5dn"
    assert_block_composition "mirrodin block", nil, ["mrd", "dst", "5dn"],
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
    assert_block_composition "time spiral block", "tsp", ["tsp", "tsb"]
    assert_block_composition "time spiral block", "tsb", ["tsp", "tsb"]
    assert_block_composition "time spiral block", "plc", ["tsp", "tsb", "plc"]
    assert_block_composition "time spiral block", "fut", ["tsp", "tsb", "plc", "fut"]
  end

  it "ravnica" do
    assert_block_composition_sequence "ravnica block", "rav", "gpt", "dis"
  end

  it "kamigawa" do
    assert_block_composition_sequence "kamigawa block", "chk", "bok", "sok"
  end

  it "lorwyn_shadowmoor" do
    assert_block_composition_sequence "lorwyn shadowmoor block", "lrw", "mor", "shm", "eve"
    assert_block_composition_sequence "lorwyn block", "lrw", "mor", "shm", "eve"
  end

  it "shards_of_alara" do
    assert_block_composition_sequence "shards of alara block", "ala", "con", "arb"
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

  # 2-set block era
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

  # Not really blocks
  it "unsets" do
    assert_block_composition "unsets", "ugl", ["ugl"],
      "Once More with Feeling" => "restricted"
    assert_block_composition "unsets", "unh", ["ugl", "unh"],
      "Once More with Feeling" => "restricted"
    assert_block_composition "unsets", "ust", ["ugl", "unh", "ust"],
      "Once More with Feeling" => "restricted"
  end
end

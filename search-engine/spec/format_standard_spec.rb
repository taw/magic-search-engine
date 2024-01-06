describe "Formats - Standard" do
  include_context "db"

  let(:regular_sets) { db.sets.values.select{|s|
    s.types.include?("core") or s.types.include?("expansion") or s.name =~ /Welcome Deck/ or s.name =~ /M19 Gift Pack/
  }.to_set }

  describe "Standard legal sets" do
    # Early Standard was not regular so we need to tweak expectations a bit
    let(:start_date) { db.sets["drk"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code) + ["3ed", "chr"] }
    let(:actual) { FormatStandard.new.rotation_schedule.values.flatten.uniq }
    it do
      expected.should match_array(actual)
    end
  end

  it "standard" do
    assert_block_composition "standard", "war",  ["xln", "rix", "dom", "m19", "g18", "grn", "rna", "war"],
      "Rampaging Ferocidon" => "banned"
    # G18 considered part of M19, but released much later
    assert_block_composition "standard", "rna",  ["xln", "rix", "dom", "m19", "grn", "g18", "rna"],
      "Rampaging Ferocidon" => "banned"
    assert_block_composition "standard", "g18",  ["xln", "rix", "dom", "m19", "grn", "g18"],
      "Rampaging Ferocidon" => "banned"
    assert_block_composition "standard", "grn",  ["xln", "rix", "dom", "m19", "grn"],
      "Rampaging Ferocidon" => "banned"
    assert_block_composition "standard", "m19",  ["kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom", "m19"],
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned",
      "Attune with Aether" => "banned",
      "Rogue Refiner" => "banned",
      "Rampaging Ferocidon" => "banned",
      "Ramunap Ruins" => "banned"
    assert_block_composition "standard", "dom",  ["kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom"],
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned",
      "Attune with Aether" => "banned",
      "Rogue Refiner" => "banned",
      "Rampaging Ferocidon" => "banned",
      "Ramunap Ruins" => "banned"
    assert_block_composition "standard", "rix",  ["kld", "aer", "akh", "w17", "hou", "xln", "rix"],
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned",
      "Attune with Aether" => "banned",
      "Rogue Refiner" => "banned",
      "Rampaging Ferocidon" => "banned",
      "Ramunap Ruins" => "banned"
    assert_block_composition "standard", "xln",  ["kld", "aer", "akh", "w17", "hou", "xln"],
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned"
    assert_block_composition "standard", "hou",  ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "akh", "w17", "hou"],
      "Emrakul, the Promised End" => "banned",
      "Reflector Mage" => "banned",
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned"
    assert_block_composition "standard", "akh",  ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "akh", "w17"],
      "Emrakul, the Promised End" => "banned",
      "Reflector Mage" => "banned",
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned"
    assert_block_composition "standard", "aer",  ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer"],
      "Emrakul, the Promised End" => "banned",
      "Reflector Mage" => "banned",
      "Smuggler's Copter" => "banned"
    assert_block_composition "standard", "kld",  ["bfz", "ogw", "soi", "w16", "emn", "kld"]
    assert_block_composition "standard", "emn",  ["dtk", "ori", "bfz", "ogw", "soi", "w16", "emn"]
    assert_block_composition "standard", "soi",  ["dtk", "ori", "bfz", "ogw", "soi", "w16"]
    assert_block_composition "standard", "ogw",  ["ktk", "frf", "dtk", "ori", "bfz", "ogw"]
    assert_block_composition "standard", "bfz",  ["ktk", "frf", "dtk", "ori", "bfz"]
    assert_block_composition "standard", "ori",  ["ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori"]
    assert_block_composition "standard", "dtk",  ["ths", "bng", "jou", "m15", "ktk", "frf", "dtk"]
    assert_block_composition "standard", "frf",  ["ths", "bng", "jou", "m15", "ktk", "frf"]
    assert_block_composition "standard", "ktk",  ["ths", "bng", "jou", "m15", "ktk"]
    assert_block_composition "standard", "m15",  ["rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15"]
    assert_block_composition "standard", "jou",  ["rtr", "gtc", "dgm", "m14", "ths", "bng", "jou"]
    assert_block_composition "standard", "bng",  ["rtr", "gtc", "dgm", "m14", "ths", "bng"]
    assert_block_composition "standard", "ths",  ["rtr", "gtc", "dgm", "m14", "ths"]
    assert_block_composition "standard", "m14",  ["isd", "dka", "avr", "m13", "rtr", "gtc", "dgm", "m14"]
    assert_block_composition "standard", "dgm",  ["isd", "dka", "avr", "m13", "rtr", "gtc", "dgm"]
    assert_block_composition "standard", "gtc",  ["isd", "dka", "avr", "m13", "rtr", "gtc"]
    assert_block_composition "standard", "rtr",  ["isd", "dka", "avr", "m13", "rtr"]
    assert_block_composition "standard", "m13",  ["som", "mbs", "nph", "m12", "isd", "dka", "avr", "m13"]
    assert_block_composition "standard", "avr",  ["som", "mbs", "nph", "m12", "isd", "dka", "avr"]
    assert_block_composition "standard", "dka",  ["som", "mbs", "nph", "m12", "isd", "dka"]
    assert_block_composition "standard", "isd",  ["som", "mbs", "nph", "m12", "isd"]
    assert_block_composition "standard", "m12",  ["zen", "wwk", "roe", "m11", "som", "mbs", "nph", "m12"],
      "Jace, the Mind Sculptor" => "banned",
      "Stoneforge Mystic" => "banned"
    assert_block_composition "standard", Date.parse("2011-07-01"), ["zen", "wwk", "roe", "m11", "som", "mbs", "nph"],
      "Jace, the Mind Sculptor" => "banned",
      "Stoneforge Mystic" => "banned"
    assert_block_composition "standard", "nph",  ["zen", "wwk", "roe", "m11", "som", "mbs", "nph"]
    assert_block_composition "standard", "mbs",  ["zen", "wwk", "roe", "m11", "som", "mbs"]
    assert_block_composition "standard", "som",  ["zen", "wwk", "roe", "m11", "som"]
    assert_block_composition "standard", "m11",  ["ala", "con", "arb", "m10", "zen", "wwk", "roe", "m11"]
    assert_block_composition "standard", "roe",  ["ala", "con", "arb", "m10", "zen", "wwk", "roe"]
    assert_block_composition "standard", "wwk",  ["ala", "con", "arb", "m10", "zen", "wwk"]
    assert_block_composition "standard", "zen",  ["ala", "con", "arb", "m10", "zen"]
    assert_block_composition "standard", "m10",  ["lrw", "mor", "shm", "eve", "ala", "con", "arb", "m10"]
    assert_block_composition "standard", "arb",  ["10e", "lrw", "mor", "shm", "eve", "ala", "con", "arb"]
    assert_block_composition "standard", "con",  ["10e", "lrw", "mor", "shm", "eve", "ala", "con"]
    assert_block_composition "standard", "ala",  ["10e", "lrw", "mor", "shm", "eve", "ala"]
    assert_block_composition "standard", "eve",  ["csp", "tsp", "tsb", "plc", "fut", "10e", "lrw", "mor", "shm", "eve"]
    assert_block_composition "standard", "shm",  ["csp", "tsp", "tsb", "plc", "fut", "10e", "lrw", "mor", "shm"]
    assert_block_composition "standard", "mor",   ["csp", "tsp", "tsb", "plc", "fut", "10e", "lrw", "mor"]
    assert_block_composition "standard", "lrw",  ["csp", "tsp", "tsb", "plc", "fut", "10e", "lrw"]
    assert_block_composition "standard", "10e",  ["rav", "gpt", "dis", "csp", "tsp", "tsb", "plc", "fut", "10e"]
    assert_block_composition "standard", "fut",  ["9ed", "rav", "gpt", "dis", "csp", "tsp", "tsb", "plc", "fut"]
    assert_block_composition "standard", "plc",  ["9ed", "rav", "gpt", "dis", "csp", "tsp", "tsb", "plc"]
    assert_block_composition "standard", "tsb",  ["9ed", "rav", "gpt", "dis", "csp", "tsp", "tsb"]
    assert_block_composition "standard", "tsp",  ["9ed", "rav", "gpt", "dis", "csp", "tsp", "tsb"]
    assert_block_composition "standard", "csp",  ["chk", "bok", "sok", "9ed", "rav", "gpt", "dis", "csp"]
    assert_block_composition "standard", "dis",  ["chk", "bok", "sok", "9ed", "rav", "gpt", "dis"]
    assert_block_composition "standard", "gpt",  ["chk", "bok", "sok", "9ed", "rav", "gpt"]
    assert_block_composition "standard", "rav",  ["chk", "bok", "sok", "9ed", "rav"]
    assert_block_composition "standard", "9ed",  ["mrd", "dst", "5dn", "chk", "bok", "sok", "9ed"],
      "Ancient Den" => "banned",
      "Arcbound Ravager" => "banned",
      "Darksteel Citadel" => "banned",
      "Disciple of the Vault" => "banned",
      "Great Furnace" => "banned",
      "Seat of the Synod" => "banned",
      "Skullclamp" => "banned",
      "Tree of Tales" => "banned",
      "Vault of Whispers" => "banned"
    assert_block_composition "standard", "sok",  ["8ed", "mrd", "dst", "5dn", "chk", "bok", "sok"],
      "Ancient Den" => "banned",
      "Arcbound Ravager" => "banned",
      "Darksteel Citadel" => "banned",
      "Disciple of the Vault" => "banned",
      "Great Furnace" => "banned",
      "Seat of the Synod" => "banned",
      "Skullclamp" => "banned",
      "Tree of Tales" => "banned",
      "Vault of Whispers" => "banned"
    assert_block_composition "standard", "bok",  ["8ed", "mrd", "dst", "5dn", "chk", "bok"],
      "Skullclamp" => "banned"
    assert_block_composition "standard", "chk",  ["8ed", "mrd", "dst", "5dn", "chk"],
      "Skullclamp" => "banned"
    assert_block_composition "standard", "5dn",  ["ons", "lgn", "scg", "8ed", "mrd", "dst", "5dn"]
    assert_block_composition "standard", "dst",  ["ons", "lgn", "scg", "8ed", "mrd", "dst"]
    assert_block_composition "standard", "mrd",  ["ons", "lgn", "scg", "8ed", "mrd"]
    assert_block_composition "standard", "8ed",  ["ody", "tor", "jud", "ons", "lgn", "scg", "8ed"]

    # Weird things happening from this point back..., ap came after 7e but will rotate earlier if I understand correctly
    # It's not guarenteed to be correct

    assert_block_composition "standard", "scg",  ["7ed", "ody", "tor", "jud", "ons", "lgn", "scg"]
    assert_block_composition "standard", "lgn",  ["7ed", "ody", "tor", "jud", "ons", "lgn"]
    assert_block_composition "standard", "ons",  ["7ed", "ody", "tor", "jud", "ons"]
    assert_block_composition "standard", "jud",  ["inv", "pls", "7ed", "apc", "ody", "tor", "jud"]
    assert_block_composition "standard", "tor",  ["inv", "pls", "7ed", "apc", "ody", "tor"]
    assert_block_composition "standard", "ody",  ["inv", "pls", "7ed", "apc", "ody"]
    assert_block_composition "standard", "apc",  ["mmq", "nem", "pcy", "inv", "pls", "7ed", "apc"]
    assert_block_composition "standard", "7ed",  ["mmq", "nem", "pcy", "inv", "pls", "7ed"]
    assert_block_composition "standard", "pls",  ["6ed", "mmq", "nem", "pcy", "inv", "pls"]
    assert_block_composition "standard", "inv",  ["6ed", "mmq", "nem", "pcy", "inv"]
    assert_block_composition "standard", "pcy",  ["usg", "ulg", "6ed", "uds", "mmq", "nem", "pcy"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "nem",   ["usg", "ulg", "6ed", "uds", "mmq", "nem"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "mmq",   ["usg", "ulg", "6ed", "uds", "mmq"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "uds",   ["tmp", "sth", "exo", "usg", "ulg", "6ed", "uds"],
      "Dream Halls" => "banned",
      "Earthcraft" => "banned",
      "Fluctuator" => "banned",
      "Lotus Petal" => "banned",
      "Memory Jar" => "banned",
      "Recurring Nightmare" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "6ed",   ["tmp", "sth", "exo", "usg", "ulg", "6ed"],
      "Dream Halls" => "banned",
      "Earthcraft" => "banned",
      "Fluctuator" => "banned",
      "Lotus Petal" => "banned",
      "Memory Jar" => "banned",
      "Recurring Nightmare" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "ulg",   ["5ed", "tmp", "sth", "exo", "usg", "ulg"],
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "usg",  ["5ed", "tmp", "sth", "exo", "usg"]
    assert_block_composition "standard", "exo",  ["mir", "vis", "5ed", "wth", "tmp", "sth", "exo"]
    assert_block_composition "standard", "sth",  ["mir", "vis", "5ed", "wth", "tmp", "sth"]
    assert_block_composition "standard", "tmp",  ["mir", "vis", "5ed", "wth", "tmp"]

    # There aren't clear blocks going that far back
    # There was also time when Standard had ABUR duals explicitly added to it...
    # This ought to be fixed someday, but it's not urgent
  end
end

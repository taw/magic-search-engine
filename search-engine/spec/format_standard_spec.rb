describe "Formats - Standard" do
  include_context "db"

  let(:regular_sets) { db.sets.values.select{|s|
    s.type == "core" or s.type == "expansion" or s.name =~ /Welcome Deck/
  }.to_set }

  describe "Standard legal sets" do
    let(:start_date) { db.sets["mr"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
    let(:actual) { FormatStandard.new.rotation_schedule.values.flatten.to_set }
    it do
      expected.should eq actual
    end
  end

  it "standard" do
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
    assert_block_composition "standard", "m11",  ["ala", "cfx", "arb", "m10", "zen", "wwk", "roe", "m11"]
    assert_block_composition "standard", "roe",  ["ala", "cfx", "arb", "m10", "zen", "wwk", "roe"]
    assert_block_composition "standard", "wwk",  ["ala", "cfx", "arb", "m10", "zen", "wwk"]
    assert_block_composition "standard", "zen",  ["ala", "cfx", "arb", "m10", "zen"]
    assert_block_composition "standard", "m10",  ["lw", "mt", "shm", "eve", "ala", "cfx", "arb", "m10"]
    assert_block_composition "standard", "arb",  ["10e", "lw", "mt", "shm", "eve", "ala", "cfx", "arb"]
    assert_block_composition "standard", "cfx",  ["10e", "lw", "mt", "shm", "eve", "ala", "cfx"]
    assert_block_composition "standard", "ala",  ["10e", "lw", "mt", "shm", "eve", "ala"]
    assert_block_composition "standard", "eve",  ["cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm", "eve"]
    assert_block_composition "standard", "shm",  ["cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm"]
    assert_block_composition "standard", "mt",   ["cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt"]
    assert_block_composition "standard", "lw",   ["cs", "ts", "tsts", "pc", "fut", "10e", "lw"]
    assert_block_composition "standard", "10e",  ["rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut", "10e"]
    assert_block_composition "standard", "fut",  ["9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut"]
    assert_block_composition "standard", "pc",   ["9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc"]
    assert_block_composition "standard", "tsts", ["9e", "rav", "gp", "di", "cs", "ts", "tsts"]
    assert_block_composition "standard", "ts",   ["9e", "rav", "gp", "di", "cs", "ts", "tsts"]
    assert_block_composition "standard", "cs",   ["chk", "bok", "sok", "9e", "rav", "gp", "di", "cs"]
    assert_block_composition "standard", "di",   ["chk", "bok", "sok", "9e", "rav", "gp", "di"]
    assert_block_composition "standard", "gp",   ["chk", "bok", "sok", "9e", "rav", "gp"]
    assert_block_composition "standard", "rav",  ["chk", "bok", "sok", "9e", "rav"]
    assert_block_composition "standard", "9e",   ["mi", "ds", "5dn", "chk", "bok", "sok", "9e"],
      "Ancient Den" => "banned",
      "Arcbound Ravager" => "banned",
      "Darksteel Citadel" => "banned",
      "Disciple of the Vault" => "banned",
      "Great Furnace" => "banned",
      "Seat of the Synod" => "banned",
      "Skullclamp" => "banned",
      "Tree of Tales" => "banned",
      "Vault of Whispers" => "banned"
    assert_block_composition "standard", "sok",  ["8e", "mi", "ds", "5dn", "chk", "bok", "sok"],
      "Ancient Den" => "banned",
      "Arcbound Ravager" => "banned",
      "Darksteel Citadel" => "banned",
      "Disciple of the Vault" => "banned",
      "Great Furnace" => "banned",
      "Seat of the Synod" => "banned",
      "Skullclamp" => "banned",
      "Tree of Tales" => "banned",
      "Vault of Whispers" => "banned"
    assert_block_composition "standard", "bok",  ["8e", "mi", "ds", "5dn", "chk", "bok"],
      "Skullclamp" => "banned"
    assert_block_composition "standard", "chk",  ["8e", "mi", "ds", "5dn", "chk"],
      "Skullclamp" => "banned"
    assert_block_composition "standard", "5dn",  ["on", "le", "sc", "8e", "mi", "ds", "5dn"]
    assert_block_composition "standard", "ds",   ["on", "le", "sc", "8e", "mi", "ds"]
    assert_block_composition "standard", "mi",   ["on", "le", "sc", "8e", "mi"]
    assert_block_composition "standard", "8e",   ["od", "tr", "ju", "on", "le", "sc", "8e"]

    # Weird things happening from this point back..., ap came after 7e but will rotate earlier if I understand correctly
    # It's not guarenteed to be correct

    assert_block_composition "standard", "sc",   ["7e", "od", "tr", "ju", "on", "le", "sc"]
    assert_block_composition "standard", "le",   ["7e", "od", "tr", "ju", "on", "le"]
    assert_block_composition "standard", "on",   ["7e", "od", "tr", "ju", "on"]
    assert_block_composition "standard", "ju",   ["in", "ps", "7e", "ap", "od", "tr", "ju"]
    assert_block_composition "standard", "tr",   ["in", "ps", "7e", "ap", "od", "tr"]
    assert_block_composition "standard", "od",   ["in", "ps", "7e", "ap", "od"]
    assert_block_composition "standard", "ap",   ["mm", "ne", "pr", "in", "ps", "7e", "ap"]
    assert_block_composition "standard", "7e",   ["mm", "ne", "pr", "in", "ps", "7e"]
    assert_block_composition "standard", "ps",   ["6e", "mm", "ne", "pr", "in", "ps"]
    assert_block_composition "standard", "in",   ["6e", "mm", "ne", "pr", "in"]
    assert_block_composition "standard", "pr",   ["us", "ul", "6e", "ud", "mm", "ne", "pr"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "ne",   ["us", "ul", "6e", "ud", "mm", "ne"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "mm",   ["us", "ul", "6e", "ud", "mm"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "ud",   ["tp", "sh", "ex", "us", "ul", "6e", "ud"],
      "Dream Halls" => "banned",
      "Earthcraft" => "banned",
      "Fluctuator" => "banned",
      "Lotus Petal" => "banned",
      "Memory Jar" => "banned",
      "Recurring Nightmare" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "6e",   ["tp", "sh", "ex", "us", "ul", "6e"],
      "Dream Halls" => "banned",
      "Earthcraft" => "banned",
      "Fluctuator" => "banned",
      "Lotus Petal" => "banned",
      "Memory Jar" => "banned",
      "Recurring Nightmare" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "ul",   ["5e", "tp", "sh", "ex", "us", "ul"],
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "us",   ["5e", "tp", "sh", "ex", "us"]
    assert_block_composition "standard", "ex",   ["mr", "vi", "5e", "wl", "tp", "sh", "ex"]
    assert_block_composition "standard", "sh",   ["mr", "vi", "5e", "wl", "tp", "sh"]
    assert_block_composition "standard", "tp",   ["mr", "vi", "5e", "wl", "tp"]

    # There aren't clear blocks going that far back
    # There was also time when Standard had ABUR duals explicitly added to it...
    # This ought to be fixed someday, but it's not urgent

    # assert_block_composition "standard", "wl",   [???, "mr", "vi", "5e", "wl"]
    # assert_block_composition "standard", "5e",   [???]
    # assert_block_composition "standard", "vi",   [???]
    # assert_block_composition "standard", "mr",   [???]
    # assert_block_composition "standard", "ai",   [???]
    # assert_block_composition "standard", "hl",   [???]
    # assert_block_composition "standard", "ia",   [???]
    # assert_block_composition "standard", "4e",   [???]
    # assert_block_composition "standard", "fe",   [???]
    # assert_block_composition "standard", "dk",   [???]
    # assert_block_composition "standard", "lg",   [???]
    # assert_block_composition "standard", "rv",   [???]
    # assert_block_composition "standard", "aq",   [???]
    # assert_block_composition "standard", "un",   [???]
    # assert_block_composition "standard", "an",   [???]
    # assert_block_composition "standard", "be",   [???]
    # assert_block_composition "standard", "al",   [???]
  end
end

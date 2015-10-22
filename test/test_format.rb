require_relative "test_helper"

class FormatTest < Minitest::Test
  def setup
    @db = load_database
  end

  def assert_block_composition(format_name, time, sets, exceptions={})
    time = @db.sets[time].release_date if time.is_a?(String)
    format = Format[format_name].new(time)
    actual_legality = @db.cards.map do |card_name, card|
      [card.name, format.legality(card)]
    end.select(&:last)
    expected_legality = Hash[sets.map{|set_code|
      @db.sets[set_code].printings.map(&:card).to_set }.inject(&:|).map{|card| [card.name, "legal"]}
    ].merge(exceptions)
    assert_hash_equal expected_legality, actual_legality, "Legality of #{format_name} at #{time}"
  end

  def assert_legality(format_name, time, card_name, status)
    time = @db.sets[time].release_date unless time.is_a?(Date)
    format = Format[format_name].new(time)
    assert_equal status, format.legality(@db.cards[card_name]), "Legality of #{card_name} in #{format_name} at #{time}"
  end

  def assert_block_composition_sequence(format_name, *sets)
    until sets.empty?
      assert_block_composition format_name, sets.last, sets
      sets.pop
    end
  end

  ## Block Constructed

  def test_ice_age_block
    assert_block_composition "ice age block", "ia", ["ia"]
    assert_block_composition "ice age block", "ai", ["ia", "ai"]
    assert_block_composition "ice age block", "cs", ["ia", "ai", "cs"],
      "Thawing Glaciers" => "banned",
      "Zuran Orb" => "banned"
  end

  def test_mirage_block
    assert_block_composition_sequence "mirage block", "mr", "vi", "wl"
  end

  def test_tempest_block
    assert_block_composition_sequence "tempest block", "tp", "sh", "ex"
  end

  def test_urza_block
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

  def test_masques_block
    assert_block_composition_sequence "masques block", "mm", "ne", "pr"
    assert_block_composition "masques block", nil, ["mm", "ne", "pr"],
      "Lin Sivvi, Defiant Hero" => "banned",
      "Rishadan Port" => "banned"
  end

  def test_invasion_block
    assert_block_composition_sequence "invasion block", "in", "ps", "ap"
  end

  def test_odyssey_block
    assert_block_composition_sequence "odyssey block", "od", "tr", "ju"
  end

  def test_onslaught_block
    assert_block_composition_sequence "onslaught block", "on", "le", "sc"
  end

  def test_mirrodin_block
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

  def test_time_spiral_block
    # Two sets released simultaneously
    assert_block_composition "time spiral block", "ts", ["ts", "tsts"]
    assert_block_composition "time spiral block", "tsts", ["ts", "tsts"]
    assert_block_composition "time spiral block", "pc", ["ts", "tsts", "pc"]
    assert_block_composition "time spiral block", "fut", ["ts", "tsts", "pc", "fut"]
  end

  def test_ravnica_block
    assert_block_composition_sequence "ravnica block", "rav", "gp", "di"
  end

  def test_kamigawa_block
    assert_block_composition_sequence "kamigawa block", "chk", "bok", "sok"
  end

  def test_lorwyn_shadowmoor_block
    assert_block_composition_sequence "lorwyn-shadowmoor block", "lw", "mt", "shm", "eve"
    assert_block_composition_sequence "lorwyn block", "lw", "mt", "shm", "eve"
  end

  def test_shards_of_alara_block
    assert_block_composition_sequence "shards of alara block", "ala", "cfx", "arb"
  end

  def test_zendikar_block
    assert_block_composition_sequence "zendikar block", "zen", "wwk", "roe"
  end

  def test_scars_of_mirrodin_block
    assert_block_composition_sequence "scars of mirrodin block", "som", "mbs", "nph"
  end

  def test_innistrad_block
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

  def test_return_to_ravnica_block
    assert_block_composition_sequence "return to ravnica block", "rtr", "gtc", "dgm"
  end

  def test_theros_block
    assert_block_composition_sequence "theros block", "ths", "bng", "jou"
  end

  def test_tarkir_block
    assert_block_composition_sequence "tarkir block", "ktk", "frf", "dtk"
  end

  def test_battle_for_zendikar
    assert_block_composition_sequence "battle for zendikar block", "bfz"
  end

  def test_unsets
    assert_block_composition_sequence "unsets", "ug", "uh"
  end

  ## Rotating formats

  def test_standard
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

  ## Eternal formats

  ## Other formats


  ## TODO

  def test_commander
  end

  def test_legacy
  end

  def test_modern
  end

  def test_vintage
  end

  def test_pauper
  end

  def test_extended
  end
end

require_relative "test_helper"

class FormatTest < Minitest::Test
  def setup
    @db = load_database
  end

  def assert_block_composition(format_name, time, sets, exceptions={})
    time = @db.sets[time].release_date unless time.is_a?(Date)
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

  def test_format_ice_age_block
    assert_block_composition_sequence "ice age block", "ia", "ai", "cs"
  end

  def test_format_mirage_block
    assert_block_composition_sequence "mirage block", "mr", "vi", "wl"
  end

  def test_format_tempest_block
    assert_block_composition_sequence "tempest block", "tp", "sh", "ex"
  end

  def test_format_urza_block
    assert_block_composition_sequence "urza block", "us", "ul", "ud"
    raise 'banlist?'
  end

  def test_format_masques_block
    assert_block_composition_sequence "masques block", "mm", "ne", "pr"
    raise 'banlist?'
  end

  def test_format_invasion_block
    assert_block_composition_sequence "invasion block", "in", "ps", "ap"
  end

  def test_format_odyssey_block
    assert_block_composition_sequence "odyssey block", "od", "tr", "ju"
  end

  def test_format_onslaught_block
    assert_block_composition_sequence "onslaught block", "on", "le", "sc"
  end

  def test_format_mirrodin_block
    assert_block_composition_sequence "mirrodin block", "mi", "ds", "5dn"
    raise 'banlist?'
  end

  def test_format_time_spiral_block
    # Two sets released simultaneously
    assert_block_composition "time spiral block", "ts", ["ts", "tsts"]
    assert_block_composition "time spiral block", "tsts", ["ts", "tsts"]
    assert_block_composition "time spiral block", "pc", ["ts", "tsts", "pc"]
    assert_block_composition "time spiral block", "fut", ["ts", "tsts", "pc", "fut"]
  end

  def test_format_ravnica_block
    assert_block_composition_sequence "ravnica block", "rav", "gp", "di"
  end

  def test_format_kamigawa_block
    assert_block_composition_sequence "kamigawa block", "chk", "bok", "sok"
  end

  def test_format_lorwyn_shadowmoor_block
    assert_block_composition_sequence "lorwyn-shadowmoor block", "lw", "mt", "shm", "eve"
    assert_block_composition_sequence "lorwyn block", "lw", "mt", "shm", "eve"
  end

  def test_format_shards_of_alara_block
    assert_block_composition_sequence "shards of alara block", "ala", "cfx", "arb"
  end

  def test_zendikar_block
    assert_block_composition_sequence "zendikar block", "zen", "wwk", "roe"
  end

  def test_format_scars_of_mirrodin_block
    assert_block_composition_sequence "scars of mirrodin block", "som", "mbs", "nph"
  end

  def test_format_innistrad_block
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

  def test_format_return_to_ravnica_block
    assert_block_composition_sequence "return to ravnica block", "rtr", "gtc", "dgm"
  end

  def test_format_theros_block
    assert_block_composition_sequence "theros block", "ths", "bng", "jou"
  end

  def test_format_tarkir_block
    assert_block_composition_sequence "tarkir block", "ktk", "frf", "dtk"
  end

  def test_format_battle_for_zendikar
    assert_block_composition_sequence "battle for zendikar block", "bfz"
  end

  ## Other formats

  def test_format_unsets
  end

  def test_format_commander
  end

  def test_format_legacy
  end

  def test_format_modern
  end

  def test_format_standard
  end


  def test_format_vintage
  end

  def test_format_pauper
  end

  def test_format_extended
  end
end

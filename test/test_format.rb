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

  ## Block Constructed

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

  ## Other formats

  def test_format_commander
  end

  def test_format_ice_age_block
  end

  def test_format_invasion_block
  end

  def test_format_kamigawa_block
  end

  def test_format_legacy
  end

  def test_format_lorwyn_shadowmoor_block
  end

  def test_format_masques_block
  end

  def test_format_mirage_block
  end

  def test_format_mirrodin_block
  end

  def test_format_modern
  end

  def test_format_odyssey_block
  end

  def test_format_onslaught_block
  end

  def test_format_ravnica_block
  end

  def test_format_return_to_ravnica_block
  end

  def test_format_scars_of_mirrodin_block
  end

  def test_format_shards_of_alara_block
  end

  def test_format_standard
  end

  def test_format_tarkir_block
  end

  def test_format_tempest_block
  end

  def test_format_theros_block
  end

  def test_format_time_spiral_block
  end

  def test_format_unsets
  end

  def test_format_urza_block
  end

  def test_format_vintage
  end

  def test_zendikar_block
  end

  def test_format_pauper
  end

  def test_format_extended
  end

  def test_format_battle_for_zendikar

  end
end

__END__

  "ia" => ["ice age block"],
  "ai" => ["ice age block"],
  "cs" => ["ice age block", "modern"],
  "mr" => ["mirage block"],
  "vi" => ["mirage block"],
  "wl" => ["mirage block"],
  "tp" => ["tempest block"],
  "sh" => ["tempest block"],
  "ex" => ["tempest block"],
  "us" => ["urza block"],
  "ul" => ["urza block"],
  "ud" => ["urza block"],
  "mm" => ["masques block"],
  "ne" => ["masques block"],
  "pr" => ["masques block"],
  "in" => ["invasion block"],
  "ps" => ["invasion block"],
  "ap" => ["invasion block"],
  "od" => ["odyssey block"],
  "tr" => ["odyssey block"],
  "ju" => ["odyssey block"],
  "on" => ["onslaught block"],
  "le" => ["onslaught block"],
  "sc" => ["onslaught block"],
  "mi" => ["modern", "mirrodin block"],
  "ds" => ["modern", "mirrodin block"],
  "5dn" => ["modern", "mirrodin block"],
  "chk" => ["modern", "kamigawa block"],
  "bok" => ["modern", "kamigawa block"],
  "sok" => ["modern", "kamigawa block"],
  "rav" => ["modern", "ravnica block"],
  "gp" => ["modern", "ravnica block"],
  "di" => ["modern", "ravnica block"],
  "ts" => ["modern", "time spiral block"],
  "tsts" => ["modern", "time spiral block"],
  "pc" => ["modern", "time spiral block"],
  "fut" => ["modern", "time spiral block"],
  "lw" => ["modern", "lorwyn-shadowmoor block"],
  "mt" => ["modern", "lorwyn-shadowmoor block"],
  "shm" => ["modern", "lorwyn-shadowmoor block"],
  "eve" => ["modern", "lorwyn-shadowmoor block"],
  "ala" => ["modern", "shards of alara block"],
  "cfx" => ["modern", "shards of alara block"],
  "arb" => ["modern", "shards of alara block"],
  "zen" => ["modern", "zendikar block"],
  "wwk" => ["modern", "zendikar block"],
  "roe" => ["modern", "zendikar block"],
  "som" => ["modern", "scars of mirrodin block"],
  "mbs" => ["modern", "scars of mirrodin block"],
  "nph" => ["modern", "scars of mirrodin block"],
  "isd" => ["modern", "innistrad block"],
  "dka" => ["modern", "innistrad block"],
  "avr" => ["modern", "innistrad block"],
  "rtr" => ["modern", "return to ravnica block"],
  "gtc" => ["modern", "return to ravnica block"],
  "dgm" => ["modern", "return to ravnica block"],
  "ths" => ["modern", "theros block"],
  "bng" => ["modern", "theros block"],
  "jou" => ["modern", "theros block"],
  "ktk" => ["standard", "modern", "tarkir block"],
  "frf" => ["standard", "modern", "tarkir block"],
  "dtk" => ["standard", "modern", "tarkir block"],
  "bfz" => ["standard", "modern"],
  "8e" => ["modern"],
  "9e" => ["modern"],
  "10e" => ["modern"],
  "m10" => ["modern"],
  "m11" => ["modern"],
  "m12" => ["modern"],
  "m13" => ["modern"],
  "m14" => ["modern"],
  "m15" => ["modern"],
  "ori" => ["standard", "modern"],

require_relative "test_helper"

class CardDatabaseTimeSpiralTest < Minitest::Test
  def setup
    @db = CardDatabase.new(Pathname(__dir__) + "index/time_spiral_block.json")
  end

  def test_is_future
    assert_search_include "is:future", "Dryad Arbor"
    assert_search_exclude "is:new", "Dryad Arbor"
    assert_search_exclude "is:old", "Dryad Arbor"
    assert_search_results "is:future is:vanilla",
      "Blade of the Sixth Pride",
      "Blind Phantasm",
      "Fomori Nomad",
      "Mass of Ghouls",
      "Nessian Courser",
      "Dryad Arbor" # not sure if it ought to be so
  end

  def test_is_new
    assert_search_exclude "is:future", "Amrou Scout"
    assert_search_include "is:new", "Amrou Scout"
    assert_search_exclude "is:old", "Amrou Scout"
  end

  def test_is_old
    assert_search_exclude "is:future", "Squire"
    assert_search_exclude "is:new", "Squire"
    assert_search_include "is:old", "Squire"
  end

  def test_is_borders
    assert_search_include "is:black-bordered", "Dryad Arbor"
    assert_search_exclude "is:white-bordered", "Dryad Arbor"
    assert_search_exclude "is:silver-bordered", "Dryad Arbor"
  end

  def test_dryad_arbor
    assert_search_include "c:g", "Dryad Arbor"
    assert_search_exclude "c:l", "Dryad Arbor"
    assert_search_exclude "c:c", "Dryad Arbor"
    assert_search_include "is:permanent", "Dryad Arbor"
    assert_search_exclude "is:spell", "Dryad Arbor"
    assert_search_results "t:land t:creature", "Dryad Arbor"
  end

  def test_ghostfire
    assert_search_exclude "c:r", "Ghostfire"
    assert_search_include "ci:r", "Ghostfire"
    assert_search_include "c:c", "Ghostfire"
  end

  def test_non_ascii
    assert_search_results "Dralnu", "Dralnu, Lich Lord"
    assert_search_results "Dralnu Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dralnu, Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dralnu , Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dandân", "Dandan"
    assert_search_results "Dandan", "Dandan"
    assert_search_results "Cutthroat il-Dal", "Cutthroat il-Dal"
    assert_search_results "Cutthroat il Dal", "Cutthroat il-Dal"
    assert_search_results "Cutthroat ildal"
    assert_search_results "Lim-Dûl the Necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Lim-Dul the Necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Lim Dul the Necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Limdul the Necromancer"
    assert_search_results "limdul necromancer"
    assert_search_results "lim dul necromancer", "Lim-Dul the Necromancer"
    assert_search_results "lim dul necromancer", "Lim-Dul the Necromancer"
    assert_search_results "Sarpadian Empires, Vol. VII", "Sarpadian Empires, Vol. VII"
    assert_search_results "sarpadian empires vol vii", "Sarpadian Empires, Vol. VII"
    assert_search_results "sarpadian empires", "Sarpadian Empires, Vol. VII"
  end

  def test_is_opposes_not
    assert_search_equal "not:future", "-is:future"
    assert_search_equal "not:new", "-is:new"
    assert_search_equal "not:old", "-is:old"
  end

  def test_is_timeshifted
    assert_count_results "is:timeshifted", 45
  end
end

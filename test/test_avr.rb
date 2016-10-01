require_relative "test_helper"

class CardDatabaseAVRTest < Minitest::Test
  def setup
    @db = load_database("avr")
  end

  def test_mana_x
    assert_search_results "mana>=xw", "Divine Deflection", "Entreat the Angels"
    assert_search_results "mana>xw", "Entreat the Angels"
    assert_search_results "mana>xx", "Entreat the Angels", "Bonfire of the Damned"
    assert_search_results "mana>={R}{X}", "Bonfire of the Damned"
  end

  def test_cn
    assert_search_results "cn:拱翼巨龙", "Archwing Dragon"
  end

  def test_tw
    assert_search_results "tw:拱翼巨龍", "Archwing Dragon"
  end

  def test_fr
    assert_search_results "fr:Fragments", "Bone Splinters"
    assert_search_results %Q[fr:"Lumière d'albâtre"], "Bruna, Light of Alabaster"
    assert_search_results %Q[fr:"lumiere d'albatre"], "Bruna, Light of Alabaster"
  end

  def test_de
    assert_search_results "de:engel",
      "Angel of Glory's Rise",
      "Angel of Jubilation",
      "Angel's Mercy",
      "Angel's Tomb",
      "Angelic Wall",
      "Archangel",
      "Avacyn, Angel of Hope",
      "Emancipation Angel",
      "Entreat the Angels",
      "Restoration Angel"
  end

  def test_it
    assert_search_results "it:clemenza", "Angel's Mercy"
  end

  def test_jp
    assert_search_results "jp:ブルーナ", "Bruna, Light of Alabaster"
  end

  def test_kr
    assert_search_results "kr:아바신", "Avacyn, Angel of Hope", "Scroll of Avacyn"
  end

  def test_pt
    assert_search_results "pt:estacas", "Bone Splinters"
  end

  def test_ru
    assert_search_results "ru:Ангел",
      "Angel of Glory's Rise",
      "Angel of Jubilation",
      "Angel's Mercy",
      "Angel's Tomb",
      "Angelic Armaments",
      "Angelic Wall",
      "Archangel",
      "Avacyn, Angel of Hope",
      "Emancipation Angel",
      "Entreat the Angels",
      "Restoration Angel"
    assert_search_equal "ru:ангел", "ru:Ангел"
    assert_search_equal "ru:АНГЕЛ", "ru:Ангел"
  end

  def test_sp
    assert_search_results "sp:Astillas", "Bone Splinters"
  end
end

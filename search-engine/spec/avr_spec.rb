describe "Avacyn Restored" do
  include_context "db", "avr"

  it "mana_x" do
    assert_search_results "mana>=xw", "Divine Deflection", "Entreat the Angels"
    assert_search_results "mana>xw", "Entreat the Angels"
    assert_search_results "mana>xx", "Entreat the Angels", "Bonfire of the Damned"
    assert_search_results "mana>={R}{X}", "Bonfire of the Damned"
  end

  it "cn" do
    assert_search_results "cn:拱翼巨龙", "Archwing Dragon"
    assert_search_results "cs:拱翼巨龙", "Archwing Dragon"
    assert_search_results "tw:拱翼巨龙"
    assert_search_results "ct:拱翼巨龙"
    # @
  end

  it "chinese_traditional" do
    assert_search_results "ct:拱翼巨龍", "Archwing Dragon"
    assert_search_results "tw:拱翼巨龍", "Archwing Dragon"
    assert_search_results "cs:拱翼巨龍"
    assert_search_results "cn:拱翼巨龍"
    # @
  end

  it "fr" do
    assert_search_results "fr:Fragments", "Bone Splinters"
    assert_search_results %Q[fr:"Lumière d'albâtre"], "Bruna, Light of Alabaster"
    assert_search_results %Q[fr:"lumiere d'albatre"], "Bruna, Light of Alabaster"
    #@
  end

  it "de" do
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
    assert_search_results %q[de:/\bdes\b/],
      "Alchemist's Refuge",
      "Angel of Glory's Rise",
      "Angel's Mercy",
      "Angel's Tomb",
      "Builder's Blessing",
      "Commander's Authority",
      "Conjurer's Closet",
      "Demonlord of Ashmouth",
      "Druid's Familiar",
      "Herald of War",
      "Midvast Protector",
      "Predator's Gambit",
      "Rush of Blood",
      "Terrifying Presence",
      "Tormentor's Trident"
  end

  it "it" do
    assert_search_results "it:clemenza", "Angel's Mercy"
    assert_search_results %q[it:/\bdell\b/],
      "Alchemist's Apprentice",
      "Alchemist's Refuge",
      "Angel of Glory's Rise",
      "Angel's Mercy",
      "Angel's Tomb",
      "Conjurer's Closet",
      "Essence Harvest",
      "Seraph of Dawn",
      "Timberland Guide",
      "Treacherous Pit-Dweller",
      "Vanguard's Shield"
  end

  it "jp" do
    assert_search_results "jp:ブルーナ", "Bruna, Light of Alabaster"
    assert_search_results %q[jp:/ブルーナ/], "Bruna, Light of Alabaster"
  end

  it "kr" do
    assert_search_results "kr:아바신", "Avacyn, Angel of Hope", "Scroll of Avacyn"
    assert_search_results %q[kr:/아바신/], "Avacyn, Angel of Hope", "Scroll of Avacyn"
  end

  it "pt" do
    assert_search_results "pt:estacas", "Bone Splinters"
    assert_search_results %q[pt:/estacas/], "Bone Splinters"
  end

  it "ru" do
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
    assert_search_equal %q[ru:/АНГЕЛ/], "ru:Ангел"
  end

  it "sp" do
    assert_search_results "sp:Astillas", "Bone Splinters"
    assert_search_results %q[sp:/astillas/], "Bone Splinters"
  end
end

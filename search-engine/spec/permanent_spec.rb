describe "is:permanent" do
  include_context "db"

  it "matches permanent types" do
    assert_search_equal "is:permanent", "t:artifact or t:battle or t:creature or t:enchantment or t:land or t:planeswalker or t:hero or t:summon or t:eaturecray or t:universewalker"
  end

  it "weird unset and special set cards" do
    # UNH Eaturecray - Igpay is just a joke spelling of a creature
    assert_search_results "e:unh t:eaturecray", "Atinlay Igpay"
    assert_search_include "is:permanent", "Atinlay Igpay"
    # PH21 Legendary Universewalker - Byode is just a joke spelling of a planeswalker
    assert_search_results "e:ph21 t:universewalker", "Byode, Inverse Sun"
    assert_search_include "is:permanent", "Byode, Inverse Sun"
    # Summon Wolf etc. is just old spelling of a creature
    assert_search_equal "t:summon", "t:summon is:permanent"
    assert_search_include "t:summon", "Old Fogey"
    # Dungeon is a nonpermanent type, but PHTR Dungeon Master is a planeswalker with Dungeon subtype
    assert_search_results "t:dungeon is:permanent", "Dungeon Master"
    assert_search_results "e:phtr t:dungeon", "Dungeon Master"
    assert_search_results "t:dungeon -is:permanent",
      "Baldur's Gate Wilderness", "Dungeon of the Mad Mage", "Lost Mine of Phandelver", "Tomb of Annihilation", "Undercity"
    # CMB1/CMB2 joke of using Instant as a supertype doesn't stop them from being creatures
    assert_search_results "e:cmb1,cmb2 t:instant t:creature", "Lightning Colt", "Visitor from Planet Q"
    assert_search_equal "e:cmb1,cmb2 t:instant t:creature", "e:cmb1,cmb2 t:instant is:permanent"
    # UNK Legendary Instant Artifact Enchantment is the same joke
    assert_search_results "e:unk t:instant is:permanent", "Blue Screen of Death"
    # Sticker sheets are not permanents
    assert_count_cards "t:stickers is:permanent", 0
    # THP1 Hero cards are a borderline case, we treat them as permanents rather than emblems
    assert_search_equal "t:hero -t:creature", "e:thp1,thp2,thp3"
    assert_search_equal "t:hero -t:creature", "t:hero -t:creature is:permanent"
  end
end

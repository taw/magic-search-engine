describe "sheet:" do
  include_context "db"

  it "is case insensitive" do
    assert_search_equal "sheet:SIS/D", "sheet:sis/d"
    assert_search_equal "sheet:sis/C2", "sheet:SIS/c2"
  end

  it "returns cards from correct sheet" do
    assert_search_results "sheet:sis/D",
      "Avacyn, Angel of Hope",
      "Avacyn's Pilgrim",
      "Balefire Dragon",
      "Barter in Blood",
      "Blazing Torch",
      "Bonds of Faith",
      "Brimstone Volley",
      "Evolving Wilds",
      "Fiend Hunter",
      "Forge Devil",
      "Garruk Relentless",
      "Geist of Saint Traft",
      "Griselbrand",
      "Havengul Lich",
      "Huntmaster of the Fells",
      "Invisible Stalker",
      "Mist Raven",
      "Sigarda, Host of Herons",
      "Snapcaster Mage",
      "Somberwald Sage",
      "Tragic Slip",
      "Vessel of Endless Rest"
  end

  it "return cards with correct multiple" do
    assert_search_results "sheet:sis/D12",
      "Avacyn's Pilgrim",
      "Blazing Torch",
      "Bonds of Faith",
      "Evolving Wilds",
      "Forge Devil",
      "Mist Raven",
      "Tragic Slip"
  end

  it "works without set given" do
    assert_search_equal "sheet:sis/d", "e:sis sheet:d"
    assert_search_equal "sheet:sis/c2", "e:sis sheet:c2"
  end

  it "works for sheets without numbers" do
    assert_search_equal "sheet:mb1/ra1", "sheet:mb1/ra"
    assert_search_equal "e:mb1 sheet:ra1", "e:mb1 sheet:ra"
  end

  it "does not have issues with overlapping sheet codes" do
    assert_search_results "sheet:mb1/r sheet:mb1/ra"
    assert_search_results "e:mb1 sheet:r sheet:ra"
  end

  it "works with cards that are on multiple sheets" do
    # Swamp cards in LEA are C5 U3 and C4 U3
    assert_search_include "sheet:lea/c", "Swamp"
    assert_search_include "sheet:lea/u", "Swamp"
    assert_search_exclude "sheet:lea/r", "Swamp"
    assert_search_include "sheet:lea/u3", "Swamp"
    assert_search_exclude "sheet:lea/u1", "Swamp"
    assert_search_include "sheet:lea/c5", "Swamp"
    assert_search_exclude "sheet:lea/c1", "Swamp"
  end
end

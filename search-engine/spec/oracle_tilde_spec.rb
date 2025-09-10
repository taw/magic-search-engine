# This used to always be card.name but it got replaced by a variety of "This <type>" phrases

describe "Oracle ~" do
  include_context "db"

  it "matches all this X phrases" do
    # Positive examples
    assert_search_include 'o:"~ enters tapped"',
      "Abandoned Campground", # land
      "Aeon Engine", # artifact
      "Alley Assailant" # creature
    assert_search_include 'o:"when ~ enters"',
      "A Killer Among Us", # enchantment
      "Aether Meltdown", # Aura
      "Aethersphere Harvester", # Vehicle
      "Alberix, the Trade Planet", # permanent
      "Ancestral Blade", # Equipment
      "Atmospheric Greenhouse", # Spacecraft
      "Blacksmith's Talent", # Class
      "Case of the Crimson Pulse", # Case
      "Atmospheric Greenhouse", # Spacecraft
      "Invasion of Arcavios", # Siege
      "Memory Test", # Attraction
      "A Girl and Her Dogs" # full card name
    assert_search_include 'o:"When you set ~ in motion"',
      "Behold My Grandeur" # scheme
    assert_search_include 'o:"return ~"',
      "Akoum Firebird" # card
    assert_search_include %q[o:"~ can't be countered"],
      "Banefire" # spell
    assert_search_include 'o:"whenever you crank ~"',
      "Accessories to Murder" # contraption
    assert_search_include 'o:"~ deals"',
      "Molten Impact", # sorcery
      "Planeswalkerificate", # planeswalker
      "Cramped Vents" # room (a bit borderline if ~ should refer to door or room)
    assert_search_include 'o:"exile ~"',
      "Behold the Unspeakable" # Saga
    assert_search_include "o:~",
      "sAnS mERcY", # plane (also test case insensitivity)
      "Occupation of Llanowar", # battle
      "Undercity", # dungeon
      "Derelict Attic", # door (a bit borderline if ~ should refer to door or room)
      "Royal Booster", # phenomenon
      "Command From the Shadows" # conspiracy

    # Negative examples - some "this X" words that shouldn't match
    assert_search_exclude 'o:"~ enters tapped"',
      "Lightstall Inquisitor" # way

    assert_search_exclude 'o:"when ~ enters"',
      "Aggressive Biomancy" # token
    assert_search_exclude 'o:"~"',
      "Abaddon the Despoiler", # turn
      "Abundance", # way
      "Academy Wall", # ability
      "Ad Nauseam", # process
      "Agatha of the Vile Cauldron", # effect
      "Akki Battle Squad", # phase
      "Aradesh, the Founder", # combat
      "Automated Artificer", # mana
      "Chance for Glory", # one
      "Commander's Insignia" # game
  end

  it "fo:" do
    assert_search_include "fo:~ -o:~",
      "Space Beleren"
  end
end

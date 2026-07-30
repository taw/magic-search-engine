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
      "Heartstone", # effect
      "Akki Battle Squad", # phase
      "Aradesh, the Founder", # combat
      "Automated Artificer", # mana
      "Chance for Glory", # one
      "Commander's Insignia" # game
  end

  # Legendary cards mostly refer to themselves by a shortened name now, and which part
  # of the name they keep isn't predictable, so the indexer mines it out of each card's
  # own text (PatchShortName). These are the shapes it needs to get right.
  it "matches short names" do
    assert_search_include 'o:"~ deals 3 damage"',
      "Ajani Vengeant" # planeswalker, drops the epithet
    assert_search_include 'o:"~ deals 13 damage"',
      "Sorin the Mirthless" # NAME the VALUE
    assert_search_include 'o:"exiled with ~"',
      "Karn Liberated" # NAME LAST
    assert_search_include 'o:"destroy all creatures except for ~"',
      "Mageta the Lion"
    assert_search_include %q[o:"~ can't block"],
      "Zurgo Bellstriker"
    assert_search_include 'o:"transform ~"',
      "Henrika Domnathi"
    assert_search_include 'o:"whenever ~ attacks"',
      "Dáin Ironfoot" # accents
    assert_search_include %q[o:"where x is ~'s power"],
      "Agatha of the Vile Cauldron" # possessive
    assert_search_include 'o:"when ~ enters"',
      "Rosie Cotton of South Lane", # two words kept
      "Borg Queen, Perfection Manifest" # everything before the comma

    # Punctuation inside the short name has to survive intact
    assert_search_include 'o:"counter on ~"',
      "Dr. Beverly Crusher" # "Dr. Crusher" - keeps the title, skips the first name
    assert_search_include 'o:"whenever ~ enters or attacks"',
      "Captain James T. Kirk" # "Captain Kirk" - skips first name and initial
    assert_search_include 'o:"as ~ enters"',
      "B.O.B. (Bevy of Beebles)"
    assert_search_include 'o:"when ~ enters, put a +1/+1 counter on target creature"',
      "SP//dr, Piloted by Peni"
    assert_search_include 'o:"whenever one or more charge counters are put on ~"',
      "U.S.S. Enterprise-D, Galaxy-Class"
    assert_search_include 'o:"whenever ~ or another human you control enters"',
      "General Kudro of Drannith"

    # Cards which never shorten their name keep working
    assert_search_include 'o:"~ deals 3 damage to any target"',
      "Lightning Bolt"
    assert_search_include 'o:"when ~ dies, create"',
      "Icingdeath, Frost Tyrant"
  end

  # Plenty of things look like a shortened name without being one. Each case checks the
  # phrase really is on the card, then that nothing at all matches once ~ takes the place
  # of the part which isn't a short name.
  it "doesn't match names which merely start out the same" do
    # Tokens and meld results named after the card
    assert_search_include 'o:"create tuktuk the returned"', "Tuktuk the Explorer"
    'o:"create ~ the returned"'.should return_no_cards
    assert_search_include 'o:"create icingdeath, frost tongue"', "Icingdeath, Frost Tyrant"
    'o:"create ~ tongue"'.should return_no_cards
    assert_search_include 'o:"into titania, gaea incarnate"', "Titania, Voice of Gaea"
    'o:"into ~ incarnate"'.should return_no_cards
    assert_search_include 'o:"create marit lage, a legendary"', "Marit Lage's Slumber"
    'o:"create ~ lage, a legendary"'.should return_no_cards
    assert_search_include 'o:"create karox bladewing"', "Verix Bladewing"
    'o:"create karox ~"'.should return_no_cards

    # Ability words containing the character's name
    assert_search_include 'o:"blade of magnus"', "Magnus the Red"
    'o:"blade of ~"'.should return_no_cards
    assert_search_include 'o:"space sculptor"', "Space Beleren"
    'o:"~ sculptor"'.should return_no_cards
    assert_search_include %q[o:"the minstrel's ballad"], "The Wandering Minstrel"
    %q[o:"~'s ballad"].should return_no_cards

    # Creature types which happen to start a legendary card's name
    assert_search_include 'o:"red dragon creature token"', "Dragon Cultist"
    'o:"red ~ creature token"'.should return_no_cards
    assert_search_include 'o:"library for a sliver card"', "Sliver Overlord"
    'o:"library for a ~ card"'.should return_no_cards
    # Rat King's short name is "Rat King", the bare creature type is not
    assert_search_include 'o:"black rat creature token"', "Rat King, Pale Piper"
    'o:"black ~ creature token"'.should return_no_cards

    # Name ending in a lowercase word - all of it is used, nothing is dropped
    assert_search_include 'o:"commander greven il-vec enters"', "Commander Greven il-Vec"
    'o:"~ il-vec enters"'.should return_no_cards

    # Modes can repeat part of a short name without being the short name
    assert_search_include 'o:"mary — create a treasure token"', "Typhoid Mary, Fractured"
    'o:"~ — create a treasure token"'.should return_no_cards
    # ... while the real one still matches
    assert_search_include 'o:"whenever ~ attacks"', "Typhoid Mary, Fractured"

    # Verix Bladewing names itself in full, so ~ is only ever the full name
    assert_search_include 'o:"verix bladewing enters"', "Verix Bladewing"
    'o:"~ bladewing enters"'.should return_no_cards
  end

  it "fo:" do
    assert_search_include "fo:~ -o:~",
      "Space Beleren"
    # Reminder text names the card too, in full ...
    assert_search_include 'fo:"~ divides the battlefield"',
      "Space Beleren"
    'o:"~ divides the battlefield"'.should return_no_cards
    # ... or shortened. o: finds this one as well, but only because funny cards
    # keep their reminder text.
    assert_search_include 'fo:"whenever ~ gains or loses loyalty"',
      "B.O.B. (Bevy of Beebles)"
  end
end

class PatchSpecialize < Patch
  # HBG Specialize, cross link them
  # (arguably we could also link to just front one)
  SpecializeGroups = [
    [
      "Alora, Rogue Companion",
      "Alora, Cheerful Assassin",
      "Alora, Cheerful Mastermind",
      "Alora, Cheerful Scout",
      "Alora, Cheerful Swashbuckler",
      "Alora, Cheerful Thief",
    ], [
      "Ambergris, Citadel Agent",
      "Ambergris, Agent of Balance",
      "Ambergris, Agent of Destruction",
      "Ambergris, Agent of Law",
      "Ambergris, Agent of Progress",
      "Ambergris, Agent of Tyranny",
    ], [
      "Gale, Conduit of the Arcane",
      "Gale, Abyssal Conduit",
      "Gale, Holy Conduit",
      "Gale, Primeval Conduit",
      "Gale, Storm Conduit",
      "Gale, Temporal Conduit",
    ], [
      "Gut, Fanatical Priestess",
      "Gut, Bestial Fanatic",
      "Gut, Brutal Fanatic",
      "Gut, Devious Fanatic",
      "Gut, Furious Fanatic",
      "Gut, Zealous Fanatic",
    ], [
      "Imoen, Trickster Friend",
      "Imoen, Chaotic Trickster",
      "Imoen, Honorable Trickster",
      "Imoen, Occult Trickster",
      "Imoen, Wily Trickster",
      "Imoen, Wise Trickster",
    ], [
      "Jaheira, Harper Emissary",
      "Jaheira, Heroic Harper",
      "Jaheira, Insightful Harper",
      "Jaheira, Merciful Harper",
      "Jaheira, Ruthless Harper",
      "Jaheira, Stirring Harper",
    ], [
      "Karlach, Raging Tiefling",
      "Karlach, Tiefling Berserker",
      "Karlach, Tiefling Guardian",
      "Karlach, Tiefling Punisher",
      "Karlach, Tiefling Spellrager",
      "Karlach, Tiefling Zealot",
    ], [
      "Klement, Novice Acolyte",
      "Klement, Death Acolyte",
      "Klement, Knowledge Acolyte",
      "Klement, Life Acolyte",
      "Klement, Nature Acolyte",
      "Klement, Tempest Acolyte",
    ], [
      "Lae'zel, Githyanki Warrior",
      "Lae'zel, Blessed Warrior",
      "Lae'zel, Callous Warrior",
      "Lae'zel, Illithid Thrall",
      "Lae'zel, Primal Warrior",
      "Lae'zel, Wrathful Warrior",
    ], [
      "Lukamina, Moon Druid",
      "Lukamina, Bear Form",
      "Lukamina, Crocodile Form",
      "Lukamina, Hawk Form",
      "Lukamina, Scorpion Form",
      "Lukamina, Wolf Form",
    ], [
      "Lulu, Forgetful Hollyphant",
      "Lulu, Curious Hollyphant",
      "Lulu, Helpful Hollyphant",
      "Lulu, Inspiring Hollyphant",
      "Lulu, Vengeful Hollyphant",
      "Lulu, Wild Hollyphant",
    ], [
      "Rasaad, Monk of Selûne",
      "Rasaad, Dragon Monk",
      "Rasaad, Radiant Monk",
      "Rasaad, Shadow Monk",
      "Rasaad, Sylvan Monk",
      "Rasaad, Warrior Monk",
    ], [
      "Sarevok the Usurper",
      "Sarevok, Deadly Usurper",
      "Sarevok, Deceitful Usurper",
      "Sarevok, Divine Usurper",
      "Sarevok, Ferocious Usurper",
      "Sarevok, Mighty Usurper",
    ], [
      "Shadowheart, Sharran Cleric",
      "Shadowheart, Cleric of Graves",
      "Shadowheart, Cleric of Order",
      "Shadowheart, Cleric of Trickery",
      "Shadowheart, Cleric of Twilight",
      "Shadowheart, Cleric of War",
    ], [
      "Skanos, Dragon Vassal",
      "Skanos, Black Dragon Vassal",
      "Skanos, Blue Dragon Vassal",
      "Skanos, Green Dragon Vassal",
      "Skanos, Red Dragon Vassal",
      "Skanos, White Dragon Vassal",
    ], [
      "Vhal, Eager Scholar",
      "Vhal, Scholar of Creation",
      "Vhal, Scholar of Elements",
      "Vhal, Scholar of Mortality",
      "Vhal, Scholar of Prophecy",
      "Vhal, Scholar of Tactics",
    ], [
      "Viconia, Nightsinger's Disciple",
      "Viconia, Disciple of Arcana",
      "Viconia, Disciple of Blood",
      "Viconia, Disciple of Rebirth",
      "Viconia, Disciple of Strength",
      "Viconia, Disciple of Violence",
    ], [
      "Wilson, Bear Comrade",
      "Wilson, Ardent Bear",
      "Wilson, Fearsome Bear",
      "Wilson, Majestic Bear",
      "Wilson, Subtle Bear",
      "Wilson, Urbane Bear",
    ], [
      "Wyll, Pact-Bound Duelist",
      "Wyll of the Blade Pact",
      "Wyll of the Celestial Pact",
      "Wyll of the Elder Pact",
      "Wyll of the Fey Pact",
      "Wyll of the Fiend Pact",
    ]
  ]

  def call
    specializes = {}
    specialized = {}
    SpecializeGroups.each do |main, *rest|
      specializes[main] = rest
      rest.each do |name|
        specialized[name] = main
      end
    end

    each_printing do |printing|
      name = printing["name"]
      if specializes[name]
        printing["specializes"] = specializes[name]
      end
      if specialized[name]
        printing["specialized"] = specialized[name]
      end
    end
  end
end

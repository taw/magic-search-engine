class ConditionIsMylittlepony < ConditionNickname
  # The My Little Pony crossover cards - the three from Ponies: The Galloping,
  # plus the Secret Lair ones (Ponies: The Galloping 2 and Discord)
  def names
    [
      "applejack",
      "discord, lord of disharmony",
      "fluttershy",
      "nightmare moon",
      "pinkie pie",
      "princess luna",
      "princess twilight sparkle",
      "rainbow dash",
      "rarity",
    ]
  end

  def to_s
    "is:mylittlepony"
  end
end

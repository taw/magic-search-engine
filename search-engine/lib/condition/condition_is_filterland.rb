class ConditionIsFilterland < ConditionNickname
  def names
    [
      "cascade bluffs",
      "cascading cataracts",
      "crystal quarry",
      "darkwater catacombs",
      "desolate mire",
      "ferrous lake",
      "fetid heath",
      "fire-lit thicket",
      "flooded grove",
      "graven cairns",
      "mossfire valley",
      "mystic gate",
      "overflowing basin",
      "rugged prairie",
      "shadowblood ridge",
      "skycloud expanse",
      "sungrass prairie",
      "sunken ruins",
      "sunscorched divide",
      "twilight mire",
      "viridescent bog",
      "wooded bastion",
    ]
  end

  def to_s
    "is:filterland"
  end
end

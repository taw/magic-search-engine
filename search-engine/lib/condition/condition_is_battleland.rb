class ConditionIsBattleland < ConditionNickname
  def names
    [
      "canopy vista",
      "cinder glade",
      "prairie stream",
      "radiant summit",
      "smoldering marsh",
      "sunken hollow",
      "vernal fen",
    ]
  end

  def to_s
    "is:battleland"
  end
end

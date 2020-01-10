class ConditionIsBattleland < ConditionNickname
  def names
    [
      "prairie stream",
      "sunken hollow",
      "smoldering marsh",
      "cinder glade",
      "canopy vista",
    ]
  end

  def to_s
    "is:battleland"
  end
end

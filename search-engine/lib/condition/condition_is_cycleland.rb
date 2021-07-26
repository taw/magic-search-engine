class ConditionIsCycleland < ConditionNickname
  def names
    [
      "canyon slough",
      "fetid pools",
      "irrigated farmland",
      "scattered groves",
      "sheltered thicket",
    ]
  end

  def to_s
    "is:cycleland"
  end
end

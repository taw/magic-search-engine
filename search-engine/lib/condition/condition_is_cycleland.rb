class ConditionIsCycleland < ConditionNickname
  def names
    [
      "canyon slough",
      "festering thicket",
      "fetid pools",
      "glittering massif",
      "irrigated farmland",
      "rain-slicked copse",
      "scattered groves",
      "sheltered thicket",
    ]
  end

  def to_s
    "is:cycleland"
  end
end

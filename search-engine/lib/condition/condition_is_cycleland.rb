class ConditionIsCycleland < ConditionNickname
  def names
    [
      "canyon slough",
      "coastal peak",
      "festering thicket",
      "fetid pools",
      "glittering massif",
      "irrigated farmland",
      "rain-slicked copse",
      "scattered groves",
      "sheltered thicket",
      "umbral expanse",
    ]
  end

  def to_s
    "is:cycleland"
  end
end

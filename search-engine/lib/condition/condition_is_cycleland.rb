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

  def explain(negated: false)
    "the card is #{negated ? "not " : ""}a cycleland"
  end
end

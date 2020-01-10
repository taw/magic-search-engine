class ConditionIsScryland < ConditionNickname
  def names
    [
      "temple of abandon",
      "temple of deceit",
      "temple of enlightenment",
      "temple of epiphany",
      "temple of malady",
      "temple of malice",
      "temple of mystery",
      "temple of plenty",
      "temple of silence",
      "temple of triumph",
    ]
  end

  def to_s
    "is:scryland"
  end
end

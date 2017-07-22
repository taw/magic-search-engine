class ConditionIsScryland < Condition
  def search(db)
    names = [
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

    names
      .map{|n| db.cards[n]}
      .flat_map{|card| card ? card.printings : []}
      .to_set
  end

  def to_s
    "is:scryland"
  end
end

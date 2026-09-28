class ConditionIsAnte < ConditionNickname
  def names
    [
      "amulet of quoz",
      "bronze tablet",
      "contract from below",
      "darkpact",
      "demonic attorney",
      "jeweled bird",
      "rebirth",
      "tempest efreet",
      "timmerian fiends",
    ]
  end

  def to_s
    "is:ante"
  end

  def explain(negated: false)
    "the card #{negated ? "doesn't involve" : "involves"} ante"
  end
end

class ConditionIsCheckland < ConditionNickname
  def names
    [
      "clifftop retreat",
      "dragonskull summit",
      "drowned catacomb",
      "glacial fortress",
      "hinterland harbor",
      "isolated chapel",
      "rootbound crag",
      "sulfur falls",
      "sunpetal grove",
      "woodland cemetery",
    ]
  end

  def to_s
    "is:checkland"
  end
end

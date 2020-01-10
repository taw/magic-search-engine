class ConditionIsShadowland < ConditionNickname
  def names
    [
      "choked estuary",
      "foreboding ruins",
      "fortified village",
      "game trail",
      "port town",
    ]
  end

  def to_s
    "is:shadowland"
  end
end

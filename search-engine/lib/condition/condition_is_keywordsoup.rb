class ConditionIsKeywordsoup < ConditionNickname
  # A card goes on this list if it lists a large number of keywords in a single sentence, and the keywords aren't ordered canonically.
  # A good indicator of this is that haste is listed before trample.
  def names
    [
      "akroma, vision of ixidor",
      "animus of predation",
      "cairn wanderer",
      "concerted effort",
      "crystalline giant",
      "death-mask duplicant",
      "greater morphling",
      "kathril, aspect warper",
      "majestic myriarch",
      "odric, lunarch marshal",
      "rayami, first of the fallen",
      "selective adaptation",
      "soulflayer",
    ]
  end

  def to_s
    "is:keywordsoup"
  end
end

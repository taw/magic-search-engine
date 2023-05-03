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
      "d00-dl, caricaturist",
      "death-mask duplicant",
      "eater of virtue",
      "greater morphling",
      "kathril, aspect warper",
      "majestic myriarch",
      "odric, blood-cursed",
      "odric, lunarch marshal",
      "priest of possibility",
      "rayami, first of the fallen",
      "selective adaptation",
      "soulflayer",
      "thunderous orator",
      "urborg scavengers",
    ]
  end

  def to_s
    "is:keywordsoup"
  end
end

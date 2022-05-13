class ConditionIsTriome < ConditionNickname
  def names
    [
      "indatha triome",
      "ketria triome",
      "raugrin triome",
      "savai triome",
      "zagoth triome",
      "jetmir's garden",
      "raffine's tower",
      "spara's headquarters",
      "xander's lounge",
      "ziatora's proving ground",
    ]
  end

  def to_s
    "is:triome"
  end
end

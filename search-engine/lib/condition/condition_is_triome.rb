class ConditionIsTriome < ConditionNickname
  def names
    [
      "indatha triome",
      "ketria triome",
      "raugrin triome",
      "savai triome",
      "zagoth triome",
    ]
  end

  def to_s
    "is:triome"
  end
end

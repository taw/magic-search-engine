class ConditionIsPermanent < ConditionSimple
  def match?(card)
    not card.types.any?{|t|
      t == "instant" or t == "sorcery" or t == "plane" or t == "scheme" or t == "phenomenon" or t == "conspiracy" or t == "vanguard"
    }
  end

  def to_s
    "is:permanent"
  end
end

class ConditionIsCustom < ConditionSimple
  def match?(card)
    false #TODO
  end

  def to_s
    "is:custom"
  end
end

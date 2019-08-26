class ConditionIsModal < ConditionSimple
  def match?(card)
    card.text =~ /(choose|opponent chooses) .*\n•/im
  end

  def to_s
    "is:modal"
  end
end

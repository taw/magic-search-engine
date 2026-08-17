# Deliberately not in the syntax help. Card#extra is an internal flag - vanguard,
# planar, scheme, conspiracy and Alchemy cards, which formats exclude from
# legality - and this exists to make it searchable while debugging that, not as
# something to tell users about.
class ConditionIsExtra < ConditionSimple
  def match?(card)
    card.extra
  end

  def to_s
    "is:extra"
  end
end

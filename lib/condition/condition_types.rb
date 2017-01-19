# FIXME: t:* is special case, it's massive hack here
class ConditionTypes < ConditionSimple
  def initialize(types)
    # urza's -> urza, same with serra's, bolas's
    @types = Set[*types.downcase.tr("’\u2212", "'-").gsub(/'s/, "").split]
    if @types.include?("*")
      @match_all = true
    else
      @match_all = false
    end
  end

  def match?(card)
    return true if @match_all
    card.types >= @types
  end

  def to_s
    "t:#{maybe_quote(@types.sort.join(' '))}"
  end
end

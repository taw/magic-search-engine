# This is in: condition, but language data already is per-card not per-printing
# so it's not ConditionIn subclass
class ConditionInForeign < ConditionSimple
  def initialize(lang)
    @lang = lang.downcase
    @lang = "ct" if @lang == "tw"
    @lang = "cs" if @lang == "cn"
    @lang = @lang.to_sym
  end

  def match?(card)
    !!card.foreign_names_normalized[@lang]
  end

  def to_s
    "in:#{maybe_quote(@lang)}"
  end
end

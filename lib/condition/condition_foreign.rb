require "unicode_utils"
class ConditionForeign < ConditionSimple
  def initialize(lang, query)
    @lang = lang
    @query = hard_normalize(query)
  end

  def match?(card)
    foreign_names = (card.foreign_names || {})[@lang] || []
    foreign_names.any?{|n|
      hard_normalize(n).include?(@query)
    }
  end

  def to_s
    "#{@lang}:#{maybe_quote(@query)}"
  end

  private

  def hard_normalize(s)
    UnicodeUtils.downcase(UnicodeUtils.nfd(s).gsub(/\p{Mn}/, ""))
  end
end

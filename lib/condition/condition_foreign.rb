require "unicode_utils"
class ConditionForeign < ConditionSimple
  def initialize(lang, query)
    @lang = lang
    @query = UnicodeUtils.downcase(query)
  end

  def match?(card)
    foreign_names = (card.foreign_names || {})[@lang] || []
    foreign_names.any?{|n|
      UnicodeUtils.downcase(n).include?(@query)
    }
  end

  def to_s
    "#{@lang}:#{maybe_quote(@query)}"
  end
end

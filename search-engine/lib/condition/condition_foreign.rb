require "unicode_utils"
class ConditionForeign < ConditionSimple
  def initialize(lang, query)
    @lang = lang.downcase
    # Support both Gatherer and MCI naming conventions
    @lang = "ct" if @lang == "tw"
    @lang = "cs" if @lang == "cn"
    @query = hard_normalize(query)
    # For CJK match anywhere
    # For others match only word boundary
    if @query == "*"
      # OK
    elsif @query =~ /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/
      @query_regexp = Regexp.new("(?:" + Regexp.escape(@query) + ")", Regexp::IGNORECASE)
    else
      @query_regexp = Regexp.new("\\b(?:" + Regexp.escape(@query) + ")\\b", Regexp::IGNORECASE)
    end
  end

  def match?(card)
    if @lang == "foreign"
      foreign_names = card.foreign_names_normalized.values.flatten
    else
      foreign_names = card.foreign_names_normalized[@lang] || []
    end
    if @query == "*"
      !foreign_names.empty?
    else
      foreign_names.any?{|n|
        n =~ @query_regexp
      }
    end
  end

  def to_s
    "#{@lang}:#{maybe_quote(@query)}"
  end

  private

  def hard_normalize(s)
    UnicodeUtils.downcase(UnicodeUtils.nfd(s).gsub(/\p{Mn}/, ""))
  end
end

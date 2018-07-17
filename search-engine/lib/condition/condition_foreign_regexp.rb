require "unicode_utils"
class ConditionForeignRegexp < ConditionRegexp
  def initialize(lang, regexp)
    @lang = lang.downcase
    # Support both Gatherer and MCI naming conventions
    @lang = "ct" if @lang == "tw"
    @lang = "cs" if @lang == "cn"
    super(regexp)
  end

  def match?(card)
    if @lang == "foreign"
      foreign_names = card.foreign_names_normalized.values.flatten
    else
      foreign_names = card.foreign_names_normalized[@lang.to_sym] || []
    end
    foreign_names.any?{|n|
      n =~ @regexp
    }
  end

  def to_s
    "#{@lang}:#{@regexp.inspect.sub(/i\z/, "")}"
  end

  private

  def hard_normalize(s)
    UnicodeUtils.downcase(UnicodeUtils.nfd(s).gsub(/\p{Mn}/, ""))
  end
end

class ConditionForeign < ConditionSimple
  WORDLESS_LANGUAGES = %i[ct cs kr jp de].to_set

  def initialize(lang, query)
    @lang = lang.downcase
    # Support both Gatherer and MCI naming conventions
    @lang = "ct" if @lang == "tw"
    @lang = "cs" if @lang == "cn"
    @lang = @lang.to_sym
    @lang_match_all = (@lang == :foreign)
    @query = hard_normalize(query)
    # For CJK match anywhere
    # For others match only word boundary
    if @query == "*"
      @query_any = true
    elsif cjk_query? or WORDLESS_LANGUAGES.include?(@lang)
      @query_regexp = compile_anywhere_match_regexp
    else
      @query_regexp = compile_word_match_regexp
    end
  end

  def match?(card)
    card.foreign_names_normalized.each do |lang, data|
      next unless @lang_match_all or lang == @lang
      # I don't think we can have empty here, it would be missing,
      # but check just in case
      if @query_any
        return true unless data.empty?
      else
        data.each do |n|
          return true if n =~ @query_regexp
        end
      end
    end
    false
  end

  def to_s
    "#{@lang}:#{maybe_quote(@query)}"
  end

  private

  def hard_normalize(s)
    s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase
  end

  def cjk_query?
    @query =~ /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/
  end

  def compile_anywhere_match_regexp
    Regexp.new("(?:" + Regexp.escape(@query) + ")", Regexp::IGNORECASE)
  end

  def compile_word_match_regexp
    Regexp.new("\\b(?:" + Regexp.escape(@query) + ")\\b", Regexp::IGNORECASE)
  end
end

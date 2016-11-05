class ConditionWord < ConditionSimple
  def initialize(word)
    @word = normalize_name(word)
    @stem_word = @word.gsub(/s\b/, "")
  end

  def match?(card)
    name = card.stemmed_name
    return true if name.include?(@stem_word)
    @suggestions.each do |alt, alt_stem|
      if name.include?(alt_stem)
        warning %Q[Trying spelling "#{alt}" in addition to "#{@word}"]
        return true
      end
    end
    false
  end

  def to_s
    "#{maybe_quote(@word)}"
  end

  def metadata=(options)
    super
    if options[:fuzzy]
      @suggestions = options[:fuzzy].suggest_spelling(@word).flat_map do |alt|
        [[alt, alt], [alt, alt.sub(/s\z/, "")]]
      end
    else
      @suggestions = []
    end
  end
end

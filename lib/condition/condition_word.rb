class ConditionWord < ConditionSimple
  def initialize(word)
    @word = normalize_name(word)
    @stem_word = apply_stemming(@word)
  end

  def match?(card)
    name = apply_stemming(card.name.downcase)
    return true if name.include?(@stem_word)
    @suggestions.each do |alt|
      if name.include?(alt)
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
      @suggestions = options[:fuzzy].suggest_spelling(@word)
    else
      @suggestions = []
    end
  end

  private

  def apply_stemming(s)
    s.gsub(/s\b/, "")
  end
end

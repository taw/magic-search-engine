class ConditionWord < ConditionSimple
  def initialize(word)
    @word = normalize_name(word).tr("-", " ").sub(/,\z/, "")
    @stem_word = @word.gsub(/s\b/, "")
  end

  def match?(card)
    name = card.stemmed_name.tr("-", " ")
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

  def metadata!(key, value)
    super
    if key == :fuzzy
      if value
        @suggestions = value.suggest_spelling(@word).flat_map do |alt|
          [[alt, alt], [alt, alt.gsub(/s\b/, "")]].uniq
        end
      else
        @suggestions = []
      end
    end
  end
end

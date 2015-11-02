require "damerau-levenshtein"

class SpellingSuggestions
  def initialize
    @words = Set[]
  end

  def <<(text)
    normalize_text(text).scan(/\w+/).each do |word|
      @words << normalize_text(word) if word.size >= 2
    end
  end

  def suggest(query)
    results1 = []
    results2 = []
    query = normalize_text(query)
    @words.each do |word|
      d = DamerauLevenshtein.distance(word, query)
      if d == 1
        results1 << word
      elsif d == 2
        results2 << word
      end
    end
    if results1.empty?
      results2.sort
    else
      results1.sort
    end
  end

  private

  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").gsub(/'s\b/, "").strip
  end
end

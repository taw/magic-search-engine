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
    # If "Rancor" is already in DB, do not suggest "Ranger" no matter what
    return [] if @words.include?(query)
    query = normalize_text(query)

    if query.size <= 2
      max_distance = 0
    elsif query.size <= 4
      max_distance = 1
    else
      max_distance = 2
    end

    results = (0...max_distance).map{ [] }
    @words.each do |word|
      d = DamerauLevenshtein.distance(word, query)
      results[d-1] << word if d <= max_distance
    end
    results.each do |r|
      return r.sort unless r.empty?
    end
    []
  end

  private

  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").gsub(/'s\b/, "").strip
  end
end

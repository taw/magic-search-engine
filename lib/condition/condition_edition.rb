class ConditionEdition < Condition
  def initialize(edition)
    @edition = normalize_text(edition)
    # FIXME: This is rather silly
    @edition_cache = Hash.new do |ht, set|
      ht[set] = set.match_set?(@edition)
    end
  end

  def match?(card)
    @edition_cache[card.set]
  end

  def to_s
    "e:#{maybe_quote(@edition)}"
  end
end

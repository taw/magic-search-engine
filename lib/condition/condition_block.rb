class ConditionBlock < Condition
  def initialize(block)
    @block = normalize_text(block)
    @block_cache = Hash.new do |ht, set|
      ht[set] = set.match_block?(@block)
    end
  end

  def match?(card)
    @block_cache[card.set]
  end

  def to_s
    "b:#{maybe_quote(@block)}"
  end
end

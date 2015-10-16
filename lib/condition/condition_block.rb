class ConditionBlock < Condition
  def initialize(block)
    @block = normalize_name(block)
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def search(db)
    block_match = Hash.new do |ht, set|
      ht[set] = if !set.block_code or !set.block_name
        false
      elsif db.blocks.include?(@block)
        set.block_code == @block or normalize_name(set.block_name) == @block
      else
        normalize_name(set.block_name).include?(@block)
      end
    end
    Set.new(db.printings.select{|card| block_match[card.set]})
  end

  def to_s
    "b:#{maybe_quote(@block)}"
  end
end

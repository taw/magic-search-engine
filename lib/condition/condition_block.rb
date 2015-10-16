class ConditionBlock < ConditionSimple
  def initialize(block)
    @block = normalize_name(block)
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def search(db)
    sets = matching_sets(db)
    Set.new(db.printings.select{|card| sets.include?(card.set_code) })
  end

  def to_s
    "b:#{maybe_quote(@block)}"
  end

  private

  def matching_sets(db)
    sets = Set[]
    db.sets.each do |set_code, set|
      next unless set.block_code and set.block_name
      if db.blocks.include?(@block)
        if set.block_code == @block or normalize_name(set.block_name) == @block
          sets << set_code
        end
      else
        if normalize_name(set.block_name).include?(@block)
          sets << set_code
        end
      end
    end
    sets
  end
end

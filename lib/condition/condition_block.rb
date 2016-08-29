class ConditionBlock < Condition
  def initialize(*blocks)
    @blocks = blocks.map{|b| normalize_name(b)}
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def search(db)
    matching_sets(db).map(&:printings).inject(Set[], &:|)
  end

  def to_s
    "b:#{@blocks.map{|b| maybe_quote(b)}.join(",")}"
  end

  private

  def matching_sets(db)
    sets = Set[]
    @blocks.each do |block|
      db.sets.each do |set_code, set|
        next unless set.block_code and set.block_name
        if db.blocks.include?(block)
          if set.block_code == block or normalize_name(set.block_name) == block
            sets << set
          end
        else
          if normalize_name(set.block_name).include?(block)
            sets << set
          end
        end
      end
    end
    sets
  end
end

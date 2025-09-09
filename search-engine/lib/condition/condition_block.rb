class ConditionBlock < Condition
  def initialize(*blocks)
    @blocks = blocks.map{|b| normalize_name(b)}
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def search(db)
    merge_into_set matching_sets(db).map(&:printings)
  end

  def to_s
    "b:#{@blocks.map{|b| maybe_quote(b)}.join(",")}"
  end

  private

  def matching_sets(db)
    sets = Set[]
    @blocks.each do |block|
      if db.blocks[block]
        sets += db.blocks[block]
      else
        matching = db.blocks.select{|name, sets| name.include?(block) }.values.sum(Set[])
        if matching
          sets += matching
        else
          warning %[Unknown block "#{block}"]
        end
      end
    end
    sets.map{|set_code| db.sets[set_code]}.to_set
  end
end

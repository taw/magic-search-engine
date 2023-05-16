class ConditionSetType < Condition
  TypeAliases = {
    "2hg" => "two-headed giant",
    "arc" => "archenemy",
    "cmd" => "commander",
    "cns" => "conspiracy",
    "dd" => "duel deck",
    "ex" => "expansion",
    "ftv" => "from the vault",
    "me" => "masters",
    "pc" => "planechase",
    "pds" => "premium deck",
    "st" => "starter",
    "std" => "standard",
    "un" => "funny",
    "unset" => "funny",
  }

  def initialize(set_type)
    set_type = normalize_name(set_type).tr("_", " ")
    @set_type = TypeAliases[set_type] || set_type
  end

  def search(db)
    merge_into_set matching_sets(db).map(&:printings)
  end

  def to_s
    "st:#{maybe_quote(@set_type)}"
  end

  private

  def matching_sets(db)
    db.sets.values.select do |set|
      set.types.include?(@set_type)
    end
  end
end

class ConditionBooster < Condition
  def initialize(*codes)
    @codes = codes
  end

  def search(db)
    @codes.flat_map{|code| matching_boosters(db, code)}.uniq.flat_map(&:cards).flat_map(&:parts).to_set
  end

  def matching_boosters(db, code)
    if code == "*"
      db.supported_booster_types.values
    elsif code =~ /\A(.*?)-?\*\z/
      set = $1
      db.supported_booster_types.values.select{|b| b.set_code == set}
    else
      [db.supported_booster_types[code]].compact
    end
  end

  def to_s
    "booster:#{maybe_quote(@codes.join(","))}"
  end
end

class ConditionBooster < Condition
  def initialize(foiling, *codes)
    @foiling = foiling
    @query = {
      "booster-foil" => :foil_cards,
      "booster-nonfoil" => :nonfoil_cards,
      "booster" => :cards,
    }.fetch(foiling)
    @codes = codes
    @codes_star = @codes.include?("*")
  end

  def search(db)
    if @codes_star
      db.printings.select(&:in_boosters).to_set
    else
      @codes.flat_map{|code| matching_boosters(db, code)}.uniq.flat_map(&@query).flat_map(&:parts).to_set
    end
  end

  def matching_boosters(db, code)
    if code =~ /\A(.*?)-?\*\z/
      set = $1
      db.supported_booster_types.values.select{|b| b.set_code == set}
    else
      [db.supported_booster_types[code]].compact
    end
  end

  def to_s
    "#{@foiling}:#{maybe_quote(@codes.join(","))}"
  end
end

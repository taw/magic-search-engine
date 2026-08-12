class ConditionBooster < Condition
  def initialize(foiling, *codes)
    @foiling = foiling
    @query = {
      "booster-foil" => :foil_cards,
      "booster-nonfoil" => :nonfoil_cards,
      "booster" => :cards,
    }.fetch(foiling)
    @codes = codes
    # in_boosters is precomputed, but it ignores foiling
    @codes_star = @codes.include?("*") && @query == :cards
  end

  def search_all(db)
    if @codes_star
      db.printings.select(&:in_boosters)
    else
      @codes.flat_map{|code| matching_boosters(db, code)}.uniq.flat_map(&@query).flat_map(&:parts).uniq
    end
  end

  def matching_boosters(db, code)
    if code.include?("*")
      pattern = booster_code_pattern(code)
      db.supported_booster_types.select{|booster_code, _| booster_code =~ pattern}.values.uniq
    else
      [db.supported_booster_types[code]].compact
    end
  end

  # Globs like "*-arena", "war-*", or "*collector*" match booster codes.
  # Trailing "-*" also matches the set's variantless booster, so "nph-*" includes "nph".
  def booster_code_pattern(code)
    prefix = code.sub(/-\*\z/, "")
    tail = (prefix == code) ? "" : "(?:-.*)?"
    /\A#{prefix.split("*", -1).map{|part| Regexp.escape(part)}.join(".*")}#{tail}\z/
  end

  def to_s
    "#{@foiling}:#{maybe_quote(@codes.join(","))}"
  end
end

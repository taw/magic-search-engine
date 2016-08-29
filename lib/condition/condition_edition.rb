class ConditionEdition < Condition
  def initialize(*editions)
    @editions = editions.map{|e| normalize_name(e)}
  end

  def search(db)
    @editions.map{|e| db.resolve_editions(e)}.inject(Set[], &:|).map(&:printings).inject(Set[], &:|)
  end

  def to_s
    "e:#{@editions.map{|e| maybe_quote(e)}.join(",")}"
  end
end

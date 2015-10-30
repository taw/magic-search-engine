class ConditionEdition < Condition
  def initialize(edition)
    @edition = normalize_name(edition)
  end

  def search(db)
    db.resolve_editions(@edition).map(&:printings).inject(Set[], &:|)
  end

  def to_s
    "e:#{maybe_quote(@edition)}"
  end
end

class ConditionLegal < ConditionFormat
  def search(db, metadata)
    db.printings.select do |card|
      legality = card.legality(@format)
      legality == "legal"
    end.to_set
  end

  def to_s
    "legal:#{maybe_quote(@format)}"
  end
end

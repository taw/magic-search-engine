class ConditionBanned < ConditionFormat
  def search(db, metadata)
    db.printings.select do |card|
      legality = card.legality(@format)
      legality == "banned"
    end.to_set
  end

  def to_s
    "banned:#{maybe_quote(@format)}"
  end
end

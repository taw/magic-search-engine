class ConditionRestricted < ConditionFormat
  def search(db)
    db.printings.select do |card|
      legality = card.legality(@format)
      legality == "restricted"
    end.to_set
  end

  def to_s
    "restricted:#{maybe_quote(@format)}"
  end
end

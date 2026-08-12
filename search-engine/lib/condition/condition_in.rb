class ConditionIn < Condition
  def search_all(db)
    results = []
    db.cards.each do |name, card|
      results.concat(card.printings) if card.printings.any?{|cp| match?(cp)}
    end
    results
  end
end

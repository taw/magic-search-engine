class ConditionIn < Condition
  def search_all(db)
    results = Set[]
    db.cards.each do |name, card|
      if card.printings.any?{|cp| match?(cp)}
        card.printings.each do |cp|
          results << cp
        end
      end
    end
    results
  end
end

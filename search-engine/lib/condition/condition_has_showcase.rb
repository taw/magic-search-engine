class ConditionHasShowcase < Condition
  def search_all(db)
    results = Set[]
    db.cards.each do |name, card|
      showcase_sets = card.printings.select{|c| c.frame_effects.include?("showcase") }.flat_map(&:set_code).to_set
      card.printings.each do |cp|
        if showcase_sets.include?(cp.set_code)
          results << cp
        end
      end
    end
    results
  end

  def to_s
    "has:showcase"
  end
end

class ConditionHasShowcase < Condition
  def search_all(db)
    results = []
    db.cards.each do |name, card|
      showcase_sets = card.printings.select{|c| c.frame_effects.include?("showcase") }.map(&:set_code).uniq
      card.printings.each do |cp|
        results << cp if showcase_sets.include?(cp.set_code)
      end
    end
    results
  end

  def to_s
    "has:showcase"
  end
end

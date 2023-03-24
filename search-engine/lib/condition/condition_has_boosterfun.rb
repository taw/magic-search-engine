class ConditionHasBoosterfun < Condition
  def search(db)
    results = Set[]
    db.cards.each do |name, card|
      showcase_sets = card.printings.select{|c| (c.frame_effects.include?("showcase") and not c.foiling.include?("foilonly")) }.flat_map(&:set_code).to_set
      borderless_sets = card.printings.select{|c| (c.border.include?("borderless") and not c.foiling.include?("foilonly")) }.flat_map(&:set_code).to_set
      card.printings.each do |cp|
        if showcase_sets.include?(cp.set_code)
          results << cp
        elsif borderless_sets.include?(cp.set_code)
          results << cp
        end
      end
    end
    results
  end
end

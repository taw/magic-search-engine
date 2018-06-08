class SetPriorityBasedReconciliation
  def initialize(printings, field_name)
    @printings = printings
    @field_name = field_name
  end

  def reconcile
    # All versions are same, or all different versions are low priority
    if max_priority_variants.size == 1
      canonical = max_priority_variants.keys[0]
      @printings.each do |printing|
        printing[@field_name] = canonical
      end
    else
      conflicting_sets = max_priority_variants.values.map{|scs| scs.join(",") }
      warn "Can't reconcile #{card_name}, need to prioritize between #{ conflicting_sets.join(" vs ") }"
    end
  end

  private

  def card_name
    @card_name ||= @printings[0]["name"]
  end

  def max_priority_variants
    @max_priority_variants ||= begin
      by_priority = {}
      @printings.each do |printing|
        set_code = printing["set_code"]
        set_priority = printing["set"]["priority"]
        variant = printing[@field_name]
        by_priority[set_priority] ||= {}
        by_priority[set_priority][variant] ||= []
        by_priority[set_priority][variant] << set_code
      end
      by_priority[by_priority.keys.max]
    end
  end
end

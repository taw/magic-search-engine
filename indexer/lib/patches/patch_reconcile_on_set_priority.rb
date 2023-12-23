class PatchReconcileOnSetPriority < Patch
  # If something is missing, it will fail validation later on,
  # only pass what you'd like to see reconciled automatically
  def fields_to_reconcile
    [
      "name",
      "mana",
      "text",
      "types",
      "subtypes",
      "supertypes",
      "rulings",
    ]
  end

  def call
    each_card do |name, printings|
      fields_to_reconcile.each do |field_name|
        # All versions are same, or all different versions are low priority
        variants = max_priority_variants(printings, field_name)
        if variants.size == 1
          canonical = variants.keys[0]
          printings.each do |printing|
            printing[field_name] = canonical
          end
        else
          conflicting_sets = variants.values.map{|scs| scs.join(",") }
          warn "Can't reconcile #{name} on #{field_name}, need to prioritize between #{ conflicting_sets.join(" vs ") }"
        end
      end
    end
  end

  def max_priority_variants(printings, field_name)
    by_priority = {}
    printings.each do |printing|
      set_code = printing["set_code"]
      set_priority = printing["set"]["priority"]
      variant = printing[field_name]
      by_priority[set_priority] ||= {}
      by_priority[set_priority][variant] ||= []
      by_priority[set_priority][variant] << set_code
    end
    by_priority[by_priority.keys.max]
  end
end

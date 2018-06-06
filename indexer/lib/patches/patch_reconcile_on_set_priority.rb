# TODO: Merge SetPriorityBasedReconciliation into this
require_relative "../set_priority_based_reconciliation"

class PatchReconcileOnSetPriority < Patch
  # If something is missing, it will fail validation later on,
  # only pass what you'd like to see reconciled automatically
  def fields_to_reconcile
    [
      "name",
      "manaCost",
      "text",
      "types",
      "subtypes",
      "supertypes",
      "rulings",
    ]
  end

  def call
    @cards.each do |name, printings|
      fields_to_reconcile.each do |field_name|
        SetPriorityBasedReconciliation.new(printings, field_name).reconcile
      end
    end
  end
end

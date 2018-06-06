# TODO: Merge OracleVerifier into this
# TODO: This blob of code should be split into multiple separate patches
require_relative "../oracle_verifier"

class PatchReconcileOracle < Patch
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
        OracleVerifier.new(printings, field_name).reconcile
      end
    end
  end
end

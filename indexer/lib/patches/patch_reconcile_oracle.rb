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
        oracle_verifier = OracleVerifier.new(printings, field_name)
        canonical = oracle_verifier.canonical
        if canonical
          printings.each do |printing|
            printing[field_name] = canonical
          end
        end
      end
    end
  end
end

# TODO: Merge OracleVerifier into this
# TODO: This blob of code should be split into multiple separate patches
require_relative "../oracle_verifier"

class PatchReconcileOracle < Patch
  def call
    @cards.each do |name, printings|
      oracle_verifier = OracleVerifier.new(name)

      printings.each do |printing|
        # If something is missing, it will fail validation later on,
        # only pass what you'd like to see reconciled automatically
        oracle_verifier.add printing["set_code"], printing.slice(
          "name",
          "manaCost",
          "text",
          "types",
          "subtypes",
          "supertypes",
          "rulings",
        )
      end

      oracle_verifier.verify!

      canonical = oracle_verifier.canonical
      printings.each do |printing|
        printing.merge!(canonical)
      end
    end
  end
end

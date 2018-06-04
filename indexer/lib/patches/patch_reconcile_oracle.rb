# TODO: Merge OracleVerifier into this
# TODO: This blob of code should be split into multiple separate patches
require_relative "../oracle_verifier"

class PatchReconcileOracle < Patch
  def call
    oracle_verifier = OracleVerifier.new

    # This is seriously awkward code here
    # If something is missing, it will fail validation later on, so it's totally fine
    @cards.each do |name, printings|
      printings.each do |printing|
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
    end

    oracle_verifier.verify!

    @cards.each do |name, printings|
      canonical = oracle_verifier.canonical(name)
      printings.each do |printing|
        printing.merge!(canonical)
      end
    end
  end
end

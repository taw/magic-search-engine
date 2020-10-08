class PatchRemoveEmptySets < Patch
  def call
    # Remove sets without cards (v4+ token only sets)
    nonempty_sets = @cards.values.flatten(1).map{|x| x["set"] }.to_set
    @sets.delete_if{|s| !nonempty_sets.include?(s) }
  end
end

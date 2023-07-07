# There's a lot of sets with just tokens
# As we don't support tokens for now, drop them
#
# On the other hand, keep no-card sets with precon decks (listed explicitly here)
class PatchRemoveEmptySets < Patch
  def call
    nonempty_sets = @cards.values.flatten(1).map{|x| x["set"]["code"] }.to_set
    # maybe add dd3 at some point
    empty_sets_to_keep = %W[q01 q02 q03 q04 q05 q07 q08].to_set

    @sets.keep_if do |s|
      nonempty_sets.include?(s["code"]) or empty_sets_to_keep.include?(s["code"])
    end
  end
end

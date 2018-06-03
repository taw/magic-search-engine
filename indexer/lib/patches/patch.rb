# This interface is completely wrong, it should be used on db not on one printing
# But refactoring step by step
class Patch
  def initialize(indexer, card)
    @indexer = indexer
    @card = card
  end

  def patch_card
    yield(@card)
  end
end

class Patch
  def initialize(cards, sets)
    @cards = cards
    @sets = sets
  end

  def patch_card(&block)
    @cards.each do |name, printings|
      printings.each(&block)
    end
  end
end

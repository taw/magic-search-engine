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

  def patch_set(&block)
    @sets.each(&block)
  end

  def cards_by_set
    @cards_by_set ||= @cards.values.flatten.group_by{|c| c["set_code"]}
  end
end

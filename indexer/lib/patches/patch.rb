class Patch
  def initialize(cards, sets, decks)
    @cards = cards
    @sets = sets
    @decks = decks
  end

  def each_card(&block)
    @cards.each(&block)
  end

  def each_printing(&block)
    @cards.each do |name, printings|
      printings.each(&block)
    end
  end

  def each_set(&block)
    @sets.each(&block)
  end

  def cards_by_set
    @cards_by_set ||= @cards.values.flatten.group_by{|c| c["set_code"]}.tap{ |h| h.default = [] }
  end

  def rename(from, to)
    raise unless @cards[from]
    @cards[from].each do |c|
      raise unless c["name"] == from
      c["name"] = to
    end

    if @cards[to]
      @cards[to] += @cards.delete(from)
    else
      @cards[to] = @cards.delete(from)
    end
  end

  def rename_printing(card, to)
    from = card["name"]
    card["name"] = to
    @cards[to] ||= []
    @cards[to] << card
    @cards[from].delete(card)
    @cards.delete(from) if @cards[from].empty?
  end

  def delete_printing_if(&block)
    @cards.each do |name, printings|
      printings.delete_if(&block)
    end
    @cards.delete_if do |name, printings|
      printings.empty?
    end
  end

  def update_names_index
    @cards.replace @cards.values.flatten(1).group_by{|c| c["name"] }
  end

  def set_by_code(code)
    @sets.find{|s| s["code"] == code} or raise "Set not found #{code}"
  end

  def inspect
    "#{self.class}"
  end
end

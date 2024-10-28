class DeckDatabase
  def initialize(db)
    @db = db
  end

  def resolve_card(count, set_code, card_number, foil=false)
    set = @db.sets[set_code] or raise "Set not found #{set_code}"
    printing = set.printings.find{|cp| cp.number == card_number}
    raise "Card not found #{set_code}/#{card_number}" unless printing
    [count, PhysicalCard.for(printing, !!foil)]
  end

  def load!(path=Pathname("#{__dir__}/../../index/deck_index.json"))
    JSON.parse(path.read).each do |deck|
      set_code = deck["set_code"]
      set = @db.sets[set_code] or raise "Set not found #{set_code}"
      sections = deck["cards"].to_h{|sn, sc| [sn, sc.map{|c| resolve_card(*c)}] }
      date = deck["release_date"]
      display = deck["display"]
      date = date ? Date.parse(date) : nil
      deck = PreconDeck.new(
        set,
        deck["name"],
        deck["type"],
        deck["category"],
        deck["format"],
        date,
        sections,
        display,
        deck["tokens"],
      )
      set.decks << deck
    end
  end
end

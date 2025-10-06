class DeckDatabase
  def initialize(db)
    @db = db
  end

  def resolve_card(count, set_code, card_number, foil=false, etched=false)
    set = @db.sets[set_code] or raise "Set not found #{set_code}"
    printing = set.printings.find{|cp| cp.number == card_number}
    raise "Card not found #{set_code}/#{card_number}" unless printing
    [count, PhysicalCard.for(printing, !!foil, !!etched)]
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
        set: set,
        name: deck["name"],
        type: deck["type"],
        category: deck["category"],
        format: deck["format"],
        release_date: date,
        sections: sections,
        display: display,
        tokens: deck["tokens"],
        languages: deck["languages"],
      )
      set.decks << deck
    end
  end
end

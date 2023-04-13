class CardSheetFactory
  def initialize(db)
    @db = db
  end

  def inspect
    "#{self.class}"
  end

  def mix_sheets(*sheets)
    sheets = sheets.select{|s,w| s}
    return nil if sheets.size == 0
    return sheets[0][0] if sheets.size == 1
    CardSheet.new(sheets.map(&:first), sheets.map{|s,w| s.elements.size * w})
  end

  def from_query(query, assert_count=nil, foil: false, kind: CardSheet)
    cards = find_cards(query, assert_count, foil: foil)
    kind.new(cards)
  end

  # This method can legitimately return 0 results
  # For example mythic subsheet for foil sheet is very often empty for older sets
  def find_cards(query, assert_count=nil, foil: false)
    base_query = "is:front"
    if foil
      base_query += " is:foil"
    else
      base_query += " is:nonfoil"
    end
    cards = @db.search("#{base_query} (#{query})").printings.map{|c| PhysicalCard.for(c, foil)}.uniq
    if assert_count and assert_count != cards.size
      warn "Expected query #{query} to return #{assert_count}, got #{cards.size}"
    end
    cards
  end

  def explicit_sheet(set_code, print_sheet_code, foil: false, count: nil)
    cards = @db.sets[set_code].printings.select{|c|
      c.print_sheet and c.print_sheet.scan(/[A-Z]+/).include?(print_sheet_code)
    }
    if count and count != cards.size
      warn "Expected sheet #{set_code}/#{print_sheet_code} to return #{count}, got #{cards.size}"
    end
    groups = cards.group_by{|c| c.print_sheet[/#{print_sheet_code}(\d+)/, 1].to_i }
    subsheets = groups.map{|mult,cards| [CardSheet.new(cards.map{|c| PhysicalCard.for(c, foil) }.uniq), mult] }
    mix_sheets(*subsheets)
  end
end

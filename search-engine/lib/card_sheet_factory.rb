class CardSheetFactory
  def initialize(db)
    @db = db
  end

  def inspect
    "#{self.class}"
  end

  def mix_sheets(*sheets, kind: CardSheet)
    sheets = sheets.select{|s,w| s}
    return nil if sheets.size == 0
    return sheets[0][0] if sheets.size == 1
    kind.new(sheets.map(&:first), sheets.map{|s,w| s.elements.size * w})
  end

  def from_query(query, assert_count=nil, foil: false, kind: CardSheet)
    cards = find_cards(query, assert_count, foil: foil)
    kind.new(cards)
  end

  # This method can legitimately return 0 results
  # For example mythic subsheet for foil sheet is very often empty for older sets
  def find_cards(query, assert_count=nil, foil: false)
    base_query = "is:mainfront"
    if foil
      base_query += " is:foil"
    else
      base_query += " is:nonfoil"
    end
    full_query = "(#{query}) #{base_query}"
    cards = @db.search(full_query).printings.map{|c| PhysicalCard.for(c, foil: foil)}.uniq
    if assert_count and assert_count != cards.size
      warn "Expected query #{full_query} to return #{assert_count}, got #{cards.size}"
    end
    cards
  end

  # print_sheet is a list of space separated codes like "U1 LL3",
  # and we want the ones whose letter part is exactly print_sheet_code
  def explicit_sheet(set_code, print_sheet_code, foil: false, count: nil, kind: CardSheet)
    match_rx = /(?<![A-Z])#{Regexp.escape(print_sheet_code)}(?![A-Z])/
    mult_rx = /#{print_sheet_code}(\d+)/
    cards = @db.sets[set_code].printings.select{|c|
      c.print_sheet and match_rx.match?(c.print_sheet)
    }
    if count and count != cards.size
      warn "Expected sheet #{set_code}/#{print_sheet_code} to return #{count}, got #{cards.size}"
    end
    groups = cards.group_by{|c| c.print_sheet[mult_rx, 1].to_i }
    subsheets = groups.map{|mult,cards| [kind.new(cards.map{|c| PhysicalCard.for(c, foil: foil) }.uniq), mult] }
    mix_sheets(*subsheets, kind: kind)
  end
end

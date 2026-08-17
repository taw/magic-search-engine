# Cards handed to the player on top of the packs they open - the promos of a
# prerelease pool, or whatever the user typed into the sealed simulator's
# "fixed cards" box.
#
# One card per line, as "2x MRD:1", "mrd:1:foil" or "mrd/1". Anything we can't
# make sense of is skipped with a warning, as the box is hand-edited and one
# bad line shouldn't cost the player the rest of their pool.
class FixedCardList
  attr_reader :cards, :warnings

  def initialize(db, text)
    @db = db
    @cards = []
    @warnings = []
    (text || "").lines.grep(/\S/).map(&:strip).each do |line|
      parse_line(line)
    end
  end

  # The line this class reads back, for links into the sealed simulator
  def self.line_for(card)
    "1x #{card.set_code}:#{card.number}#{card.foil ? ":foil" : ""}"
  end

  private

  SEPARATOR = %r[\s*[:/]\s*]

  def parse_line(line)
    case line
    when /\A(\d+)\s*x?\s*(.*[:\/].*)/i
      count = $1.to_i
      set_code, number, foil = $2.downcase.split(SEPARATOR, 3)
    when /\A(.*[:\/].*)/i
      count = 1
      set_code, number, foil = line.downcase.split(SEPARATOR, 3)
    else
      @warnings << "Invalid line: #{line}"
      return
    end

    set = @db.sets[set_code]
    unless set
      @warnings << "Cannot find set with code: #{set_code} for line: #{line}"
      return
    end
    printing = set.printings.find{|c| c.number.downcase == number}
    unless printing
      @warnings << "Cannot find card set with number #{number} in set #{set_code} for line: #{line}"
      return
    end

    card = PhysicalCard.for(printing, foil == "foil")
    count.times{ @cards << card }
  end
end

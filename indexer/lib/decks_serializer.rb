class DecksSerializer
  def initialize(decks)
    @decks = decks
  end

  def to_s
    @decks.to_json
  end
end

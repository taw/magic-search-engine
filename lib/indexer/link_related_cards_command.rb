# Maybe the whole process should be a bunch of commands...
class LinkRelatedCardsCommand
  def initialize(cards)
    @cards = cards
  end

  def call
    @links = {}
    # Get longest match so
    # "Take Inventory" doesn't mistakenly seem to refer to "Take" etc.
    # Second regexp for empire series
    any_card = Regexp.union(@cards.keys.sort_by(&:size).reverse)
    rx = /\bnamed (#{any_card})(?:(?:,|,? and|,? or) (#{any_card}))?(?:(?:,|,? and|,? or) (#{any_card}))?/
    @cards.each do |name, card_data|
      matching_cards = (card_data["text"]||"").scan(rx).flatten.uniq - [name, nil]
      next if matching_cards.empty?
      matching_cards.each do |other|
        @links[name] ||= Set[]
        @links[name] << other
        @links[other] ||= Set[]
        @links[other] << name
      end
    end
    @links.each do |name, others|
      @cards[name]["related"] = others.sort
    end
  end
end

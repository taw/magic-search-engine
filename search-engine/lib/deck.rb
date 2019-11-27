class Deck
  attr_reader :cards, :sideboard

  def initialize(cards, sideboard)
    @cards = cards
    @sideboard = sideboard
  end

  def cards_with_sideboard
    result = Hash.new(0)
    [*@cards, *@sideboard].each do |number, card|
      result[card] += number
    end
    result.map(&:reverse)
  end

  def card_counts
    result = {}
    cards_with_sideboard.each do |number, physical_card|
      card = physical_card.main_front.card
      result[card] ||= [physical_card.name, 0]
      result[card][1] += number
    end
    result.map{|card,(name,number)| [card, name, number] }
  end

  def number_of_mainboard_cards
    @cards.sum(&:first)
  end

  def number_of_sideboard_cards
    @sideboard.sum(&:first)
  end

  def number_of_total_cards
    number_of_mainboard_cards + number_of_sideboard_cards
  end

  def physical_cards
    [*@cards.map(&:last), *@sideboard.map(&:last)].uniq
  end

  def physical_card_names
    physical_cards.map(&:name).uniq
  end

  def valid_commander?
    case number_of_sideboard_cards
    when 1
      a = @sideboard[0][1]
      a.commander?
    when 2
      return false unless @sideboard.size == 2 # 2x same card is not valid
      a = @sideboard[0][1]
      b = @sideboard[1][1]
      a.commander? and b.commander? and a.valid_partner_for?(b)
    else
      false
    end
  end

  def valid_brawler?
    case number_of_sideboard_cards
    when 1
      a = @sideboard[0][1]
      a.brawler?
    when 2
      return false unless @sideboard.size == 2 # 2x same card is not valid
      a = @sideboard[0][1]
      b = @sideboard[1][1]
      a.brawler? and b.brawler? and a.valid_partner_for?(b)
    else
      false
    end
  end

  def color_identity
    return nil unless number_of_sideboard_cards.between?(1, 2)
    @sideboard.map{|n,c| c.color_identity}.inject{|c1, c2| (c1.chars | c2.chars).sort.join }
  end
end

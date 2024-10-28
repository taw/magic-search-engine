class Deck
  attr_reader :cards, :sideboard, :commander, :tokens

  def initialize(sections, tokens=[])
    @sections = sections
    @cards = sections["Main Deck"]
    @sideboard = (sections["Sideboard"] || []) + (sections["Planar Deck"] || []) + (sections["Display Commander"] || []) + (sections["Scheme Deck"] || [])
    @commander = sections["Commander"] || []
    @tokens = tokens
  end

  def cards_in_all_zones
    result = Hash.new(0)
    [*@cards, *@sideboard, *@commander].each do |number, card|
      result[card] += number
    end
    result.map(&:reverse)
  end

  def sideboard_and_commander
    result = Hash.new(0)
    [*@sideboard, *@commander].each do |number, card|
      result[card] += number
    end
    result.map(&:reverse)
  end

  def card_counts
    result = {}
    cards_in_all_zones.each do |number, physical_card|
      card = physical_card.main_front.card
      result[card] ||= [physical_card.name, 0]
      result[card][1] += number
    end
    result.map{|card,(name,number)| [card, name, number] }
  end

  def section(name)
    @sections[name] || []
  end

  def number_of_cards(section)
    return 0 unless @sections[section]
    @sections[section].sum(&:first)
  end

  def number_of_mainboard_cards
    number_of_cards("Main Deck")
  end

  def number_of_sideboard_cards
    number_of_cards("Sideboard")
  end

  def number_of_commander_cards
    number_of_cards("Commander")
  end

  def number_of_total_cards
    @sections.values.map{|cs| cs.sum(&:first)}.sum
  end

  def physical_cards
    @sections.values.flat_map{|sc| sc.map(&:last)}.uniq
  end

  def physical_card_names
    physical_cards.map(&:name).uniq
  end

  # Wizard from Beyond not implemented
  def valid_commander?
    case number_of_commander_cards
    when 1
      a = @commander[0][1]
      a.commander?
    when 2
      return false unless @commander.size == 2 # 2x same card is not valid
      a = @commander[0][1]
      b = @commander[1][1]
      a.commander? and b.commander? and a.valid_partner_for?(b)
    else
      false
    end
  end

  def valid_brawler?
    case number_of_commander_cards
    when 1
      a = @commander[0][1]
      a.brawler?
    when 2
      return false unless @commander.size == 2 # 2x same card is not valid
      a = @commander[0][1]
      b = @commander[1][1]
      a.brawler? and b.brawler? and a.valid_partner_for?(b)
    else
      false
    end
  end

  def color_identity
    return nil unless number_of_commander_cards.between?(1, 2)
    @commander.map{|n,c| c.color_identity}.inject{|c1, c2| (c1.chars | c2.chars).sort.join }
  end

  def all_set_codes
    @sections.values.flat_map{|sc| sc.map{|_,card| card.set_code}}.to_set
  end

  def all_cards
    @sections.values.flatten(1)
  end
end

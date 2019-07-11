class Deck
  attr_reader :set, :name, :type, :release_date, :cards, :sideboard, :slug
  def initialize(set, name, type, release_date, cards, sideboard)
    @set = set
    @name = name
    @type = type
    @release_date = release_date
    @cards = cards
    @sideboard = sideboard
    @slug = @name.downcase.gsub("'s", "s").gsub(/[^a-z0-9s]+/, "-")
  end

  def cards_with_sideboard
    result = Hash.new(0)
    [*@cards, *@sideboard].each do |number, card|
      result[card] += number
    end
    result.map(&:reverse)
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

  def inspect
    "Deck<#{set.name} - #{@name} - #{@type}>"
  end

  def all_set_codes
    @all_set_codes ||= [*@cards, *@sideboard].map{|_,card| card.set_code}.to_set
  end

  def set_code
    @set.code
  end

  def set_name
    @set.name
  end

  def to_s
    inspect
  end

  def inspect
    "Deck<#{@name}>"
  end

  def to_text
    output = []
    output << "// NAME: #{@name} - #{@set.name} #{@type}"
    output << "// URL: http://mtg.wtf/deck/#{set.code}/#{slug}"
    output << "// DATE: #{@release_date.to_s}" if @release_date
    @cards.each do |count, card|
      output << "#{count} #{card}"
    end
    unless @sideboard.empty?
      output << ""
      output << "Sideboard"
      @sideboard.each do |count, card|
        output << "#{count} #{card}"
      end
    end
    output.join("\n") + "\n"
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
end

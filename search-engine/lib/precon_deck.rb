class PreconDeck < Deck
  attr_reader :set, :name, :type, :release_date, :slug
  def initialize(set, name, type, release_date, cards, sideboard)
    super(cards, sideboard)
    @set = set
    @name = name
    @type = type
    @release_date = release_date
    @slug = @name.downcase.gsub("'s", "s").gsub(/[^a-z0-9s]+/, "-")
  end

  def inspect
    "PreconDeck<#{set.name} - #{@name} - #{@type}>"
  end

  def to_s
    inspect
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
end

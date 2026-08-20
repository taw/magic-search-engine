class PreconDeck < Deck
  attr_reader :set, :name, :type, :category, :format, :release_date, :slug, :source, :display, :normalized_name, :languages
  def initialize(set:, name:, type:, category:, format:, release_date:, sections:, display:, tokens:, languages:, source:)
    super(sections, tokens)
    @set = set
    @name = name
    @type = type
    @category = category
    @format = format
    @release_date = release_date
    @slug = @name.downcase.gsub("'s", "s").gsub(/[^a-z0-9s]+/, "-").chomp("-")
    @display = display
    @normalized_name = @name.downcase.gsub("'s", "").delete(",").normalize_accents
    @languages = Array(languages)
    @source = source
  end

  def inspect
    "PreconDeck<#{set.name} - #{@name} - #{@type}>"
  end

  def to_s
    inspect
  end

  def set_code
    @set.code
  end

  def set_name
    @set.name
  end

  def canonical_url
    "http://mtg.wtf/deck/#{set.code}/#{slug}"
  end

  # "Blood Rush - Dragon's Maze Event Deck" - the deck's name plus what it is,
  # which is what the page title and the export header both want
  def full_name
    "#{@name} - #{@set.name} #{@type}"
  end
end

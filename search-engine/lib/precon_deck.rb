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

  # Everything except "Main Deck" and "Commander", which get special treatment
  EXPORTED_SECTIONS = ["Sideboard", "Planar Deck", "Display Commander", "Scheme Deck"]

  def to_text
    deck_text{|cards| group_by_name(cards) }
  end

  def to_text_with_printings
    deck_text{|cards| cards.map{|count, card| [count, card_details(card)] } }
  end

  # This groups multiple different basics etc. together
  def card_names(section_name=nil)
    group_by_name(section_name ? section(section_name) : @cards)
  end

  def card_details(card)
    [
      "#{card}",
      " [#{card.set_code.upcase}:#{card.number}]",
      card.foil ? " [foil]" : "",
      card.etched ? " [etched]" : "",
    ].join
  end

  private

  def group_by_name(cards)
    result = Hash.new(0)
    cards.each do |count, card|
      result[card.to_s] += count
    end
    result.map{|k,v| [v,k]}
  end

  # Display text can have multiple lines, and every one of them needs to be
  # commented out, or a parser will read the rest as cards
  def display_comment
    @display.to_s.lines.map(&:chomp).map.with_index do |line, i|
      i == 0 ? "// DISPLAY: #{line}" : "// #{line}"
    end
  end

  # Both exports have the same structure, they only differ in how much
  # information each card line carries
  def deck_text(&format)
    output = []
    output << "// NAME: #{@name} - #{@set.name} #{@type}"
    output << "// URL: #{canonical_url}"
    output.concat(display_comment)
    output << "// DATE: #{@release_date}" if @release_date
    format[@commander].each do |count, card|
      output << "COMMANDER: #{count} #{card}"
    end
    format[@cards].each do |count, card|
      output << "#{count} #{card}"
    end
    EXPORTED_SECTIONS.each do |section_name|
      next if section(section_name).empty?
      output << ""
      output << section_name
      format[section(section_name)].each do |count, card|
        output << "#{count} #{card}"
      end
    end
    output.join("\n") + "\n"
  end
end

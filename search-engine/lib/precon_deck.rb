class PreconDeck < Deck
  attr_reader :set, :name, :type, :category, :format, :release_date, :slug, :source, :display, :normalized_name
  def initialize(set, name, type, category, format, release_date, sections, display)
    super(sections)
    @set = set
    @name = name
    @type = type
    @category = category
    @format = format
    @release_date = release_date
    @slug = @name.downcase.gsub("'s", "s").gsub(/[^a-z0-9s]+/, "-").chomp("-")
    @display = display
    @normalized_name = @name.downcase.gsub("'s", "").delete(",").normalize_accents
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

  def to_text
    output = []
    output << "// NAME: #{@name} - #{@set.name} #{@type}"
    output << "// URL: http://mtg.wtf/deck/#{set.code}/#{slug}"
    output << "// DISPLAY: #{@display}" if @display
    output << "// DATE: #{@release_date}" if @release_date
    @commander.each do |count, card|
      output << "COMMANDER: #{count} #{card}"
    end
    @cards.each do |count, card|
      output << "#{count} #{card}"
    end
    ["Sideboard", "Planar Deck", "Display Commander", "Scheme Deck"].each do |section_name|
      unless section(section_name).empty?
        output << ""
        output << section_name
        section(section_name).each do |count, card|
          output << "#{count} #{card}"
        end
      end
    end
    output.join("\n") + "\n"
  end
end

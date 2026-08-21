# Turns whatever the user uploaded into decklist text DeckParser can read
class UserDeckPreprocessor
  attr_reader :text

  def initialize(data)
    @data = data
    convert_xml or normalize_text
  end

  def valid?
    !@error
  end

  private

  def convert_xml
    begin
      doc = Nokogiri::XML(@data)
      return false unless doc.errors.empty? and !doc.root.nil?
    rescue
      return false
    end

    case doc.root.name
    when "cockatrice_deck"
      main = doc.css("zone[name=main] card").map{|c| "#{cockatrice_card(c)}\n" }.join
      side = doc.css("zone[name=side] card").map{|c| "SB: #{cockatrice_card(c)}\n" }.join
      @text = "#{main}\n#{side}"
      return true
    when "Deck"
      side, main = doc.css("Cards").partition{|c| c["Sideboard"] == "true" }
      main = main.map{|c| "#{c["Quantity"]}x #{c["Name"]}\n" }.join
      side = side.map{|c| "SB: #{c["Quantity"]}x #{c["Name"]}\n" }.join
      @text = "#{main}\n#{side}"
      return true
    else
      return false
    end
  end

  # A .cod card carries a printing as well as a name - our own export writes one
  # on every card - and the collector number in it is the physical card's, which
  # is what DeckParser falls back to when our per-face number does not match.
  def cockatrice_card(card)
    line = "#{card["number"]}x #{card["name"]}"
    return line unless card["setShortName"]
    return line + " [#{card["setShortName"]}]" unless card["collectorNumber"]
    line + " [#{card["setShortName"]}:#{card["collectorNumber"]}]"
  end

  def normalize_text
    if @data.force_encoding('utf-8').valid_encoding?
      @data = @data.force_encoding('utf-8').sub(/\ufeff/, "")
    else
      begin
        @data = @data.force_encoding("cp1252").encode("utf-8")
      rescue
        # Binary data
        @error = true
        @data = ""
      end
    end
    @data = @data.gsub(/\r\n|\r|\n/, "\n")
    # XMage has metadata we seriously don't care for
    # (maybe we could use NAME: ???)
    @data = @data.gsub(/^(NAME:|AUTHOR:|LAYOUT MAIN:|LAYOUT SIDEBOARD:).*\n/, "")

    # MTGO text Format marks sideboard with empty line
    # Every other text format ignores empty lines
    # Arena-style lists use empty lines between sections they name themselves,
    # and their second block is usually the deck, not the sideboard
    if !labelled_sections? and @data.split(/\n\n/).size == 2
      main, side = @data.split(/\n\n/, 2)
      side = side.lines.map{|x| "SB: #{x}" }.join
      @data = "#{main}\n\n#{side}"
    end

    @text = @data
  end

  def labelled_sections?
    return true if @data =~ /^\s*SB:/i
    @data.lines.any?{|line| DeckParser.section_header(line.strip) }
  end
end

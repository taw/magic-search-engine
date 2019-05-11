class UserDeckParser
  def initialize(data)
    @data = data
    # XML
    try_parse_xml or try_parse_text
  end

  def deck
    @deck
  end

  def valid?
    !@error
  end

  private

  def try_parse_xml
    begin
      doc = Nokogiri::XML(@data)
      return false unless doc.errors.empty? and !doc.root.nil?
    rescue
      return false
    end

    case doc.root.name
    when "cockatrice_deck"
      main = doc.css("zone[name=main] card").map{|c| "#{c["number"]}x #{c["name"]}\n" }.join
      side = doc.css("zone[name=side] card").map{|c| "SB: #{c["number"]}x #{c["name"]}\n" }.join
      @deck = "#{main}\n#{side}"
      return true
    when "Deck"
      side, main = doc.css("Cards").partition{|c| c["Sideboard"] == "true" }
      main = main.map{|c| "#{c["Quantity"]}x #{c["Name"]}\n" }.join
      side = side.map{|c| "SB: #{c["Quantity"]}x #{c["Name"]}\n" }.join
      @deck = "#{main}\n#{side}"
      return true
    else
      return false
    end
  end

  def try_parse_text
    # Text
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
    @deck = @data.gsub(/\r\n|\r|\n/, "\n")
  end
end

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
      return false unless doc.errors.empty?
    rescue
      return false
    end

    puts "MAYBE ITS XML"
    return false
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

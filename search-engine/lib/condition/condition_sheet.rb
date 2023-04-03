class ConditionSheet < ConditionSimple
  def initialize(sheet)
    parts = sheet.downcase.split("/", 2)
    if parts.size == 2
      @set, sheet = parts[0], parts[1]
    else
      @set = nil
      sheet = parts[0]
    end
    if sheet =~ /\A([A-Z]+)(\d+)\z/i
      @sheet = $1
      @mult = $2
      if @mult == "1"
        @rx = /\b(#{Regexp.escape(@sheet+@mult)}|#{Regexp.escape(@sheet)})\b/i
      else
        @rx = /\b#{Regexp.escape(@sheet+@mult)}\b/i
      end
    else
      @sheet = sheet
      @mult = nil
      @rx = /\b#{Regexp.escape(@sheet)}\d*\b/i
    end
  end

  def match?(card)
    return false unless card.print_sheet
    if @set
      return false unless @set == card.set_code
    end
    !!(card.print_sheet =~ @rx)
  end

  def to_s
    "sheet:#{maybe_quote("#{@set && "#{@set}/"}#{@sheet}#{@mult}")}"
  end
end

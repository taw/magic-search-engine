class LegalityInformation
  def initialize(card, time=nil)
    @card = card
    @time = time
    @result = {}
    Format.all_format_classes.each do |format_class|
      format = format_class.new(time)
      status = format.legality(card)
      @result[format.format_pretty_name] = status
    end
    @result
  end

  def legal_everywhere?
    @result.values.all?
  end

  def legal_nowhere?
    @result.values.none?
  end

  def to_h
    @result.select{|k,v| v}
  end
end

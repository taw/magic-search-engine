class Format
  def initialize(time)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @time = time
    @ban_list = BanList.new
  end

  def legality(card)
    if in_format?(card)
      @ban_list.legality(format_name, card.name, @time)
    else
      nil
    end
  end

  def in_format?(card)
    any_printing?(card){|printing| format_sets.include?(printing.set_code) }
  end

  def format_name
    raise "Subclass responsibility"
  end

  def format_sets
    raise "SubclassResponsibility"
  end

  private

  def any_printing?(card, &blk)
    if @time
      card.printings.select{|printing| printing.release_date <= @time}.any?(&blk)
    else
      card.printings.any?(&blk)
    end
  end

  def self.[](format)
    {
      "innistrad block" => FormatInnistradBlock,
    }[format].tap do |format_class|
      raise "Unknown format #{format}" unless format_class
    end
  end
end

Dir["#{__dir__}/format_*.rb"].each do |path| require_relative path end

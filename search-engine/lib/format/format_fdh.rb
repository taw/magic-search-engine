class FormatFDH < Format
  def initialize(time=nil)
    super(time)
    @included_sets = build_included_sets
    @excluded_sets = build_excluded_sets
    @real_ban_list = BanList["commander"]
    @custom_ban_list = BanList["custom eternal"]
  end

  def format_pretty_name
    "Fusion Dragon Highlander"
  end

  def include_custom_sets?
    true
  end

  def build_included_sets
    Format["custom eternal"].new(@time).build_included_sets
  end

  def build_excluded_sets
    Format["commander"].new(@time).build_excluded_sets
  end

  def in_format?(card)
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      if card.custom?
        next unless @included_sets.include?(printing.set_code)
      else
        next if @excluded_sets.include?(printing.set_code)
      end
      return true
    end
    false
  end

  def legality(card)
    status = super(card)
    return status if status != "legal"
    if card.custom?
      @custom_ban_list.legality(card.name, @time)
    else
      @real_ban_list.legality(card.name, @time)
    end
  end
end

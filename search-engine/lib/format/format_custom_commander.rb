class FormatCustomCommander < Format
  def initialize(time=nil)
    super(time)
    @real_ban_list = BanList["commander"]
    @custom_ban_list = BanList["custom eternal"]
  end

  def format_pretty_name
    "Custom Commander"
  end

  def include_custom_sets?
    true
  end

  def build_excluded_sets
    FormatCommander[@time].build_excluded_sets
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

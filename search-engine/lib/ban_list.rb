class BanList
  START = Date.parse("1900-01-01")

  def initialize(format)
    @format = format
    @events = []
    @cards = {}
  end

  def legality(card_name, time)
    statuses = @cards[card_name] || [[START, "legal"]]
    if time
      status = "legal"
      statuses.each do |change_time, leg|
        break if time and change_time > time
        status = leg
      end
      status
    else
      statuses.last.last
    end
  end

  def full_ban_list(time)
    result = {}
    @cards.each_key do |card_name|
      status = legality(card_name, time)
      result[card_name] = status unless status == "legal"
    end
    result
  end

  def events
    events = {}
    @cards.each do |card_name, card_events|
      [[nil, "legal"], *card_events].each_cons(2) do |(d1, l1), (d2, l2)|
        events[d2] ||= []
        events[d2] << {name: card_name, old: l1, new: l2}
      end
    end

    events.sort.reverse.map do |date,evs|
      url = @events.find{|d,_,_| d == date}[1]
      date = nil if date == START
      [date, url, evs]
    end
  end

  def change_dates
    @events.map{|d,_,_| d}
  end

  private

  def format_start(url, legalities)
    change(START, url, legalities)
  end

  def change(date, url, legalities)
    date = Date.parse(date) unless date.is_a?(Date)
    @events << [date, url, legalities]
    legalities.each do |card, legality|
      @cards[card] ||= []
      @cards[card] << [date, legality]
    end
  end

  def validate
    dates = @events.map(&:first)
    raise "#{self} not sorted" unless dates.sort == dates
      raise "#{self} has multiples of same date" if dates.uniq != dates
    @cards.each do |card_name, legalities|
      dates = legalities.map(&:first)
      status = legalities.map(&:last)
      raise "#{self} for #{card_name} not sorted" unless dates.sort == dates
      raise "#{self} for #{card_name} starts with legal, which is redundant" if status[0] == "legal"
      raise "#{self} for #{card_name} has transition to same status" if status.each_cons(2).any?{|before, after| before==after}
    end
  end

  def to_s
    "BanList[#{@format}]"
  end

  class << self
    # BanList for each format is singleton
    def [](format)
      @ban_lists ||= {}
      @ban_lists[format] ||= BanList.new(format)
    end

    def for_format(format, &block)
      ban_list = self[format]
      ban_list.instance_eval(&block)
      ban_list.instance_eval{ validate }
    end

    def all_change_dates
      @ban_lists.values.flat_map(&:change_dates).uniq.sort
    end
  end
end

Dir["#{__dir__}/ban_list/*.rb"].each do |path| require_relative path end

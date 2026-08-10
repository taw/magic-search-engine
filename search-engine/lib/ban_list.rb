class BanList
  START = Date.parse("1900-01-01")

  # The only statuses the engine itself understands
  LEGALITY_STATUSES = ["legal", "banned", "restricted"].freeze

  # Statuses ban lists are allowed to say, and what they currently collapse to.
  # "restricted" is doing the work of four unrelated rules concepts, and these
  # names are the first step of untangling it - see _LEGALITY.md.
  LEGALITY_ALIASES = {
    # legal in the deck, but may not be your commander (Commander, Duel Commander, Brawl)
    "banned_as_commander" => "restricted",
    # legal in the deck, but may not be your companion (Commander)
    "banned_as_companion" => "restricted",
    # Arena-only card that can only be conjured, never put in a deck (Historic, Alchemy)
    "conjurable" => "restricted",
    # Arena-only card that only enters play by specializing another card (Historic, Alchemy)
    "specialized" => "restricted",
  }.freeze

  attr_reader :format

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

  # Announcements as declared, [date, url, {card name => legality}]
  # Unlike events it doesn't split them by card or figure out previous legality
  def changes
    @events
  end

  def to_s
    "BanList[#{@format}]"
  end

  private

  def format_start(url, legalities)
    change(START, url, legalities)
  end

  def change(date, url, legalities)
    date = Date.parse(date) unless date.is_a?(Date)
    legalities = legalities.map{|card, legality| [card, normalize_legality(legality)]}.to_h
    @events << [date, url, legalities]
    legalities.each do |card, legality|
      @cards[card] ||= []
      @cards[card] << [date, legality]
    end
  end

  # Ban lists say what they actually mean, the engine only understands the three
  # statuses below, so the specific ones collapse back to "restricted" here.
  # Nothing downstream can tell them apart yet - see _LEGALITY.md.
  def normalize_legality(legality)
    return legality if LEGALITY_STATUSES.include?(legality)
    LEGALITY_ALIASES[legality] or raise "#{self} has unknown legality status #{legality.inspect}"
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

    # Formats get a BanList even if they never had any bans, skip those
    def all_ban_lists
      @ban_lists.values.reject{|ban_list| ban_list.changes.empty?}.sort_by(&:format)
    end
  end
end

Dir["#{__dir__}/ban_list/*.rb"].each do |path| require_relative path end

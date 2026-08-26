class BanList
  START = Date.parse("1900-01-01")

  # Every status a ban list is allowed to say. The last four used to be spelled
  # "restricted" as well, which meant nothing downstream could tell them apart -
  # Format::RESTRICTED_STATUSES is what groups them back together now.
  LEGALITY_STATUSES = [
    "legal",
    "banned",
    # only 1 copy in a deck instead of 4 (Vintage, historically Standard)
    "restricted",
    # legal in the deck, but may not be your commander (Commander, Duel Commander, Standard Brawl)
    "banned_as_commander",
    # legal in the deck, but may not be your companion (Commander, Duel Commander)
    "banned_as_companion",
    # Arena-only card that can only be conjured, never put in a deck (Historic, Alchemy)
    "conjurable",
    # Arena-only card that only enters play by specializing another card (Historic, Alchemy)
    "specialized",
  ].freeze

  # Statuses the DSL accepts on top of those, mapped to a real one before anything
  # downstream sees them.
  #
  # "prebanned" is an ordinary ban announced before the card was available anywhere.
  # We record when a change took effect, not when it was announced, so its date is the
  # card's release date (Arena release date for digital-only formats) rather than the
  # announcement date - which is what specs will eventually check it for.
  DSL_STATUS_ALIASES = {
    "prebanned" => "banned",
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

  # Announcements split by card, newest first, as [date, url, comment, [{name:, old:, new:}, ...]]
  # Date is nil for the announcement which established the initial ban list.
  def events
    events = {}
    @cards.each do |card_name, card_events|
      [[nil, "legal"], *card_events].each_cons(2) do |(d1, l1), (d2, l2)|
        events[d2] ||= []
        events[d2] << {name: card_name, old: l1, new: l2}
      end
    end

    events.sort.reverse.map do |date,evs|
      announcement = @events.find{|event| event[:date] == date}
      date = nil if date == START
      [date, announcement[:url], announcement[:comment], evs]
    end
  end

  def change_dates
    @events.map{|event| event[:date]}
  end

  # Announcements as declared, {date:, url:, comment:, changes: {card name => legality}}
  # Unlike events it doesn't split them by card or figure out previous legality
  def changes
    @events
  end

  def to_s
    "BanList[#{@format}]"
  end

  private

  def format_start(source, legalities)
    change(START, source, legalities)
  end

  # source is either a link to the announcement, or a plain text comment saying
  # where the information came from. The DSL only takes one of them, but nothing
  # downstream should assume that an event can't have both.
  def change(date, source, legalities)
    date = Date.parse(date) unless date.is_a?(Date)
    legalities = legalities.transform_values{|legality| DSL_STATUS_ALIASES.fetch(legality, legality)}
    legalities.each_value do |legality|
      raise "#{self} has unknown legality status #{legality.inspect}" unless LEGALITY_STATUSES.include?(legality)
    end
    if source =~ %r{\Ahttps?://}
      url, comment = source, nil
    else
      url, comment = nil, source
    end
    @events << {date: date, url: url, comment: comment, changes: legalities}
    legalities.each do |card, legality|
      @cards[card] ||= []
      @cards[card] << [date, legality]
    end
  end

  def validate
    dates = @events.map{|event| event[:date]}
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

Dir["#{__dir__}/ban_list/*.rb"].sort.each do |path| require_relative path end

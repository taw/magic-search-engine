require_relative "query_parser"
require_relative "search_results"
require "digest"

class Date
  # Any kind of key for sorting
  def to_i_sort
    to_time.to_i
  end
end

class Query
  attr_reader :warnings

  def initialize(query_string)
    @query_string = query_string
    @cond, @metadata, @warnings = QueryParser.new.parse(query_string)
    # puts "Parse #{query_string} -> #{@cond}"
  end

  def search(db)
    logger = Set[*@warnings]
    if @cond
      @cond.metadata! :logger, logger
      @cond.metadata! :fuzzy, nil
      results = @cond.search(db)
      if results.empty?
        @cond.metadata! :fuzzy, db
        results = @cond.search(db)
      end
    else
      results = db.printings
    end

    SearchResults.new(sort_results(results), logger, ungrouped?)
  end

  def to_s
    str = [
      @cond.to_s,
      # ("time:#{maybe_quote(@metadata[:time])}" if @metadata[:time]),
      ("sort:#{@metadata[:sort]}" if @metadata[:sort]),
    ].compact.join(" ")
    (@metadata[:ungrouped] ? "++#{str}" : str)
  end

  def ==(other)
    # structural equality, subclass if you need something fancier
    # We ignore @query_string, so queries that == won't necessarily have same random order
    # It's something we might want to revisit someday
    self.class == other.class and
      instance_variables == other.instance_variables and
      instance_variables.all?{|ivar|
        ivar == :@query_string or
        instance_variable_get(ivar) == other.instance_variable_get(ivar)
      }
  end

  def view
    @metadata[:view]
  end

  private

  COLOR_ORDER = ["w", "u", "b", "r", "g", "uw", "bu", "br", "gr", "gw", "bw", "ru", "bg", "rw", "gu", "buw", "bru", "bgr", "grw", "guw", "brw", "gru", "bgw", "ruw", "bgu", "bruw", "bgru", "bgrw", "gruw", "bguw", "bgruw", ""].each_with_index.to_h.freeze

  # Fallback sorting for printings of each card:
  # * custom set
  # * not MTGO only
  # * new frame
  # * Standard only printing
  # * most recent
  # * set name
  # * card number as integer (10 > 2)
  # * card number as string (10A > 10)
  def sort_results(results)
    case @metadata[:sort]
    when "new"
      results.sort_by do |c|
        [c.set.regular? ? 0 : 1, -c.release_date_i, c.default_sort_index]
      end
    when "old"
      results.sort_by do |c|
        [c.set.regular? ? 0 : 1, c.release_date_i, c.default_sort_index]
      end
    when "newall"
      results.sort_by do |c|
        [-c.release_date_i, c.default_sort_index]
      end
    when "oldall"
      results.sort_by do |c|
        [c.release_date_i, c.default_sort_index]
      end
    when "cmc"
      results.sort_by do |c|
        [c.cmc ? 0 : 1, -c.cmc.to_i, c.default_sort_index]
      end
    when "pow"
      results.sort_by do |c|
        [c.power ? 0 : 1, -c.power.to_i, c.default_sort_index]
      end
    when "tou"
      results.sort_by do |c|
        [c.toughness ? 0 : 1, -c.toughness.to_i, c.default_sort_index]
      end
    when "rand"
      results.sort_by do |c|
        [Digest::MD5.hexdigest(@query_string + c.name), c.default_sort_index]
      end
    when "number"
      results.sort_by do |c|
        [c.set.name, c.number.to_i, c.number, c.default_sort_index]
      end
    when "color"
      results.sort_by do |c|
        [COLOR_ORDER.fetch(c.colors), c.default_sort_index]
      end
    when "ci"
      results.sort_by do |c|
        [COLOR_ORDER.fetch(c.color_identity), c.default_sort_index]
      end
    when "rarity"
      results.sort_by do |c|
        [-c.rarity_code, c.default_sort_index]
      end
    else # "name" or unknown key
      results.sort_by(&:default_sort_index)
    end
  end

  def ungrouped?
    !!@metadata[:ungrouped]
  end

  def maybe_quote(text)
    if text.is_a?(Date)
      '"%d.%d.%d"' % [text.year, text.month, text.day]
    elsif text =~ /\A[a-zA-Z0-9]+\z/
      text
    else
      text.inspect
    end
  end
end

class FormatAny < Format
  # Everything here is `any?` over every format, so the order decides how soon
  # it can stop. Commander is legal for 91% of cards, Historic picks up the
  # Arena-only ones, and Unsets is the only format that takes funny cards, which
  # every other format rejects outright. That answers all but 1,669 cards by the
  # third check - and 1,653 of those are legal nowhere, so they have to be tried
  # against everything however they're ordered.
  #
  # Resolved on first use rather than in a constant, as format_any.rb loads
  # before most of the format classes exist.
  def self.ordered_format_classes
    @ordered_format_classes ||=
      [FormatCommander, FormatHistoric, FormatUnsets] | Format.all_format_classes
  end

  def initialize(time=nil)
    raise ArgumentError unless time.nil? or time.is_a?(Date)
    @formats = self.class.ordered_format_classes.map{|f| f.new(time)}
  end

  def format_pretty_name
    "Any format"
  end

  def banned?(card)
    @formats.any?{|fmt| fmt.banned?(card)}
  end

  def restricted?(card)
    @formats.any?{|fmt| fmt.restricted?(card)}
  end

  def legal?(card)
    @formats.any?{|fmt| fmt.legal?(card)}
  end

  def legal_or_restricted?(card)
    legal?(card) or restricted?(card)
  end

  def included_sets
    nil
  end

  def excluded_sets
    nil
  end
end

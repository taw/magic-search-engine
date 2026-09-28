# Printings which are the first ones for a card to have some property,
# like the first printing with a given artist, or the first one available in foil.
#
# A printing matches if it has a value no earlier printing of the same card had.
# Printings released the same day all count as new, as there's no meaningful
# order between them. A printing with no value for the property, like one with
# no watermark for new:watermark, never counts as new.
class ConditionNew < ConditionSimple
  # Properties with at most one value per printing
  SINGLE = {
    "artist"    => ->(c) { c.artist_name },
    "border"    => ->(c) { c.border },
    "flavor"    => ->(c) { flavor = c.flavor_normalized; flavor unless flavor.empty? },
    "foil"      => ->(c) { "foil" if c.any_foil? },
    "frame"     => ->(c) { c.frame },
    "nonfoil"   => ->(c) { "nonfoil" if c.has_finish?(:nonfoil) },
    "rarity"    => ->(c) { c.rarity },
    "watermark" => ->(c) { c.watermark },
  }.freeze

  # Properties with any number of values per printing
  MULTIPLE = {
    "frameeffect" => ->(c) { c.frame_effects },
    "game"        => ->(c) { c.games },
  }.freeze

  PROPERTIES = (SINGLE.keys + MULTIPLE.keys).sort.freeze

  ALIASES = {
    "flavortext"   => "flavor",
    "flavour"      => "flavor",
    "frameeffects" => "frameeffect",
    "ft"           => "flavor",
    "illustrator"  => "artist",
    "wm"           => "watermark",
  }.freeze

  def initialize(property)
    @property = property
    @single = SINGLE[property]
    @multiple = MULTIPLE[property]
    raise "Unknown new: property #{property}" unless @single or @multiple
  end

  def match?(card)
    printings = card.card.printings
    date = card.release_date_i
    if @single
      value = @single.call(card)
      return false unless value
      printings.none? do |other|
        other.release_date_i < date and @single.call(other) == value
      end
    else
      values = @multiple.call(card)
      return false if values.empty?
      values.any? do |value|
        printings.none? do |other|
          other.release_date_i < date and @multiple.call(other).include?(value)
        end
      end
    end
  end

  def to_s
    "new:#{@property}"
  end

  # There's no one specific value to name (explain doesn't know which artist, which
  # watermark, ...) - just that this printing is the first of its card to have one,
  # so "printed with a new X" reads better than an empty "the first printing with
  # this X".
  PHRASES = {
    "artist" => "the card was printed with a new artist",
    "border" => "the card was printed with a new border",
    "flavor" => "the card was printed with new flavor text",
    "foil" => "the card was first printed in foil",
    "frame" => "the card was printed with a new frame",
    "nonfoil" => "the card was first printed in nonfoil",
    "rarity" => "the card was printed at a new rarity",
    "watermark" => "the card was printed with a new watermark",
    "frameeffect" => "the card was printed with a new frame effect",
    "game" => "the card was first added to a new game",
  }.freeze
  NEGATED_PHRASES = {
    "artist" => "the card was not printed with a new artist",
    "border" => "the card was not printed with a new border",
    "flavor" => "the card was not printed with new flavor text",
    "foil" => "the card was not first printed in foil",
    "frame" => "the card was not printed with a new frame",
    "nonfoil" => "the card was not first printed in nonfoil",
    "rarity" => "the card was not printed at a new rarity",
    "watermark" => "the card was not printed with a new watermark",
    "frameeffect" => "the card was not printed with a new frame effect",
    "game" => "the card was not first added to a new game",
  }.freeze

  def explain(negated: false)
    (negated ? NEGATED_PHRASES : PHRASES).fetch(@property)
  end
end

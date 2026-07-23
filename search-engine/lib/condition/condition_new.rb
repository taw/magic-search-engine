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
    "foil"      => ->(c) { "foil" unless c.foiling == :nonfoil },
    "frame"     => ->(c) { c.frame },
    "nonfoil"   => ->(c) { "nonfoil" unless c.foiling == :foilonly },
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
end

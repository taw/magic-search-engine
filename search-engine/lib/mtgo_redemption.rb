require "csv"
require "yaml"
require "pathname"

# Which sets can be redeemed for a physical set on MTGO. Both data files can be
# read without running anything - the decklist generator is only one of their
# users. Redemption is announced per set on https://www.mtgo.com/news/
class MtgoRedemption
  REDEMPTION_PATH = Pathname(__dir__) + "../../data/mtgo_redemption.csv"
  NOT_REDEEMABLE_PATH = Pathname(__dir__) + "../../data/mtgo_not_redeemable.yaml"

  # MTGO redemption only ever covered Standard-legal sets, and only since
  # Invasion
  FIRST_REDEEMABLE_RELEASE_DATE = Date.parse("2000-10-02")

  # Name column is just for our convenience, we always use set name from db
  def rows
    @rows ||= CSV.read(
      REDEMPTION_PATH,
      headers: true,
      header_converters: :symbol,
      converters: [:integer, :date]
    )
  end

  def set_codes
    rows.map{|row| row[:code].downcase}
  end

  # Set code => where we know it from
  def not_redeemable
    @not_redeemable ||= YAML.load_file(NOT_REDEEMABLE_PATH)
  end

  # Sets we'd expect to be redeemable, but which aren't in the data file yet.
  # Sets we only have a partial spoiler for aren't out yet, so nobody announced
  # their redemption either.
  def missing_set_codes(db)
    standard_sets = db.sets.values.select{|set|
      set.release_date >= FIRST_REDEEMABLE_RELEASE_DATE and
        set.types.include?("standard") and
        !set.types.include?("preview")
    }
    standard_sets.map(&:code) - set_codes - not_redeemable.keys
  end

  def missing_redemptions_warning(db)
    missing = missing_set_codes(db)
    return nil if missing.empty?
    "These sets should probably be redemable on MTGO: #{missing.join(" ")}" \
      " - check https://www.mtgo.com/news/ and update data/mtgo_redemption.csv"
  end
end

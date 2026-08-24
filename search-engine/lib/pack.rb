# Ignoring marketing/token cards completely
class Pack
  def initialize(sheets)
    @sheets = sheets
  end

  def open
    result = []
    @sheets.each do |sheet, count|
      result.push *sheet.random_cards_without_duplicates(count)
    end
    result
  end

  ## Metadata

  attr_accessor :set, :code, :name, :languages

  def set_name
    @set&.name
  end

  def set_code
    @set&.code
  end

  # Memoized because CardDatabase#availability asks every booster there is
  # whether it could hold a card from one set before it scans any of them
  def source_set_codes
    @source_set_codes ||= @sheets.keys.flat_map(&:source_set_codes).uniq.sort
  end

  # Every sheet the pack can draw from, for callers that want to look inside
  # rather than open it. A sheet is shared by every booster that uses it, so
  # the same one can come up twice and it is the caller that dedupes.
  def each_sheet(&block)
    @sheets.each_key(&block)
  end

  # Testing support
  # Also used by booster: queries

  attr_reader :sheets

  def expected_values
    result = Hash.new(0)
    @sheets.each do |sheet, count|
      # sample and sample_without_duplicates have same expected value
      sheet.probabilities.each do |card, probability|
        result[card] += probability * count
      end
    end
    result
  end

  def cards
    @sheets.keys.flat_map(&:cards).uniq
  end

  def foil_cards
    cards.select(&:foil)
  end

  def nonfoil_cards
    cards.reject(&:foil)
  end

  def has_foils?
    cards.any?(&:foil)
  end
end

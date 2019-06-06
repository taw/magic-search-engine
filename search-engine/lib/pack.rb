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

  ## Testing support

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
    expected_values.keys
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

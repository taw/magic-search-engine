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

class ReubenPack < Pack
  def open
    while true
      cards = super
      # rule 1 (interpreting “of the same color” as “sharing a color”)
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("w")} <= 4
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("u")} <= 4
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("b")} <= 4
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("r")} <= 4
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("g")} <= 4
      # rule 2
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("w")} >= 1
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("u")} >= 1
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("b")} >= 1
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("r")} >= 1
      next unless cards.count{|c| c.rarity == "common" && c.main_front.colors.include?("g")} >= 1
      # rule 3
      next unless cards.count{|c| c.rarity == "common" && c.main_front.types.include?("creature")} > 0
      # rule 4 (interpreting “of the same color” as “sharing a color”)
      next unless cards.count{|c| c.rarity == "uncommon" && c.main_front.colors.include?("w")} <= 2
      next unless cards.count{|c| c.rarity == "uncommon" && c.main_front.colors.include?("u")} <= 2
      next unless cards.count{|c| c.rarity == "uncommon" && c.main_front.colors.include?("b")} <= 2
      next unless cards.count{|c| c.rarity == "uncommon" && c.main_front.colors.include?("r")} <= 2
      next unless cards.count{|c| c.rarity == "uncommon" && c.main_front.colors.include?("g")} <= 2
      # (rule 5 is already implemented in super)
      return cards
    end
  end
end

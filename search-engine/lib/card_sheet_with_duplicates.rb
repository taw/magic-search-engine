class CardSheetWithDuplicates < CardSheet
  # Just ignore the "without duplicates" part
  def random_cards_without_duplicates(count)
    count.times.map{ random_card }
  end
end

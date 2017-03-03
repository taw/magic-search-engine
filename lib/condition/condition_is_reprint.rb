class ConditionIsReprint < Condition
  def search(db)
    reprints = Set[]
    db.cards.each do |key, card|
      first_print_date = card.printings.map(&:release_date).min
      card.printings.each do |printing|
        reprints << printing if printing.release_date != first_print_date
      end
    end
    reprints
  end

  def to_s
    "is:reprint"
  end
end

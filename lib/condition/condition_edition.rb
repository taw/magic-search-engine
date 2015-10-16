class ConditionEdition < Condition
  def initialize(edition)
    @edition = normalize_name(edition)
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def search(db)
    edition_match = Hash.new do |ht, set|
      ht[set] = if db.sets[@edition]
        set.set_code == @edition or normalize_name(set.set_name) == @edition
      else
        normalize_name(set.set_name).include?(@edition)
      end
    end
    Set.new(db.printings.select{|card| edition_match[card.set]})
  end

  def to_s
    "e:#{maybe_quote(@edition)}"
  end
end

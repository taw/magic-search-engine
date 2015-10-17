class ConditionEdition < Condition
  def initialize(edition)
    @edition = normalize_name(edition)
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def search(db)
    matching_sets(db).map(&:printings).inject(Set[], &:|)
  end

  def to_s
    "e:#{maybe_quote(@edition)}"
  end

  private

  def matching_sets(db)
    sets = Set[]
    db.sets.each do |set_code, set|
      if db.sets[@edition]
        if set_code == @edition or normalize_name(set.set_name) == @edition
          sets << set
        end
      else
        if normalize_name(set.set_name).include?(@edition)
          sets << set
        end
      end
    end
    sets
  end
end

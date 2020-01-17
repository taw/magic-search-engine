class PatchAssignPrioritiesToSets < Patch
  def call
    each_set do |set|
      set["priority"] = priority(set)
    end
  end

  private

  def priority(set)
    # Errata sets are just a way to apply Oracle erratas without creating any cards
    return 1000 if set["types"].include?("errata")

    # Give all unlisted custom sets max priority
    # If you want to customize priority between different custom sets, just list them explicitly
    return 100 if set["custom"]

    # case set["code"]
    # when "pwar", "prm", "eld", "celd"
    #   return 5
    # end

    return 10 if set["v4"]
    # Default priority for everything else
    0
  end
end

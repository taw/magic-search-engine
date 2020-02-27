class PatchAssignPrioritiesToSets < Patch
  def call
    @versions = [nil, *@sets.map{|x| x.dig("meta", "date") }.uniq.sort]

    each_set do |set|
      set["priority"] = priority(set)
    end
  end

  private

  def priority(set)
    # Errata sets are just a way to apply Oracle erratas without creating any cards
    return 2000 if set["types"].include?("errata")

    # Give all unlisted custom sets max priority
    # If you want to customize priority between different custom sets, just list them explicitly
    return 1000 if set["custom"]

    if set["v4"]
      # Automatically make more recent sets take priority
      date = set.dig("meta", "date")
      return 10 + @versions.index(date)
    end
    # Default priority for everything else
    0
  end
end

class PatchAssignPrioritiesToSets < Patch
  def call
    each_set do |set|
      set["priority"] = priority(set)
    end
  end

  private

  def priority(set)
    # Errata sets are just a way to apply Oracle erratas without creating any cards
    return 1000 if set["type"] == "errata"

    # Give all unlisted custom sets max priority
    # If you want to customize priority between different custom sets, just list them explicitly
    return 100 if set["custom"]

    # v4 migration started by manually choosing some sets to migrate
    return 10 if set["v4"]
    # These sets have been tried but need fixing:
    # tsp tsb plc fut
    # chk bok sok
    # isd dka


    case set["code"]
    # These are mostly various promos which are not on Gatherer
    # They never get updated, but since their cards have other printings in regular sets,
    # they'll still get all Oracle updates via reconciliation
    when *%W[
      st2k v17 cp1 cp2 cp3
      prel rqs parl itp ath pmpr pwos p2hg dpa pjgp pcmp pgtw ppre psus pfnm ppro pmgd plpa
      dkm cst plgm pwpn mgb psum p15a pgpx pwcq
    ]
      -10
      # v4 still has issues
    else
      # Default priority for everything else
      0
    end
  end
end

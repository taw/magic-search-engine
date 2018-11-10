class PatchAssignPrioritiesToSets < Patch
  def call
    each_set do |set|
      set["priority"] = priority(set)
    end
  end

  private

  def priority(set)
    case set["code"]
    # These are mostly various promos which are not on Gatherer
    # They never get updated, but since their cards have other printings in regular sets,
    # they'll still get all Oracle updates via reconciliation
    when *%W[
           ced cei bok st2k v17 cp1 cp2 cp3
           prel pmei rqs parl itp ath pmpr pwos p2hg dpa pjgp pcmp pgtw ppre psus pfnm ppro pmgd plpa
           dkm cst plgm pwpn mgb psum p15a pgpx pwcq
         ]
      -10
      # v4 still has issues
    when "gk1"
      -1
    when "grn"
      1
    else
      # Errata sets are just a way to apply Oracle erratas without creating any cards
      if set["type"] == "errata"
        1000
        # Give all unlisted custom sets max priority
        # If you want to customize priority between different custom sets, just list them explicitly
      elsif set["custom"]
        100
        # Default priority for everything else
      else
        0
      end
    end
  end
end

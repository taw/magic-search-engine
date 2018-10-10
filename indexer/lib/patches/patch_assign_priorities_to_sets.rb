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
        rep mbp rqs arena itp ath mprp wotc thgt dpa jr cp gtw ptc sus jr fnmp pro mgdc mlp
        dkm cst dcilm wpn mgb sum 15ann gpx wmcq
      ]
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

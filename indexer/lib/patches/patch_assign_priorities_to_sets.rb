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
        ced cedi bok st2k v17 cp1 cp2 cp3
        rep mbp rqs arena itp at mprp wotc thgt dpa jr cp gtw ptc sus jr fnmp pro mgdc mlp
        dm cstd dcilm wpn mgbc sum 15ann gpx wmcq
      ]
      -1
    # whichever sets got updated since last full mtgjson update
    when "dom", "bbd", "ss1", "gs1", "cm2"
      1
    else
      # Give all unlisted custom sets max priority
      # If you want to customize priority between different custom sets, just list them explicitly
      if set["custom"]
        100
      else
      # Default priority for everything else
        0
      end
    end
  end
end

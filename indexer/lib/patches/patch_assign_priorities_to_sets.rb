class PatchAssignPrioritiesToSets < Patch
  def call
    each_set do |set|
      set["priority"] = priority(set)
    end
  end

  private

  def priority(set)
    case set["code"]
    # v4 migration started by manually choosing some sets to migrate
    when *%W[
      lea leb 2ed 3ed 4ed 6ed 7ed 8ed 9ed
      ced cei
      leg fem ice hml
      m10 m11 m12 m13 m14 m15 m19
      rav gpt dis
      lrw mor shm eve
      ala con arb
      zen wwk roe
      som msb nph
      avr
      rtr gtc dgm
      ths bng jou
      ktk frf dtk
    ]
    # These sets have been tried but need fixing:
    # tsp tsb plc fut
    # chk bok sok
    # isd dka

      10
    # These are mostly various promos which are not on Gatherer
    # They never get updated, but since their cards have other printings in regular sets,
    # they'll still get all Oracle updates via reconciliation
    when *%W[
        st2k v17 cp1 cp2 cp3
        prel pmei rqs parl itp ath pmpr pwos p2hg dpa pjgp pcmp pgtw ppre psus pfnm ppro pmgd plpa
        dkm cst plgm pwpn mgb psum p15a pgpx pwcq
      ]
      -10
      # v4 still has issues
    when "gk1", "uma", "puma", "rna"
      -1
    when "grn"
      1
    when "med"
      2
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

class ConditionIsPathway < ConditionNickname
  def names
    [
      "barkchannel pathway",
      "tidechannel pathway",
      "blightstep pathway",
      "searstep pathway",
      "branchloft pathway",
      "boulderloft pathway",
      "brightclimb pathway",
      "grimclimb pathway",
      "clearwater pathway",
      "murkwater pathway",
      "cragcrown pathway",
      "timbercrown pathway",
      "darkbore pathway",
      "slitherbore pathway",
      "hengegate pathway",
      "mistgate pathway",
      "needleverge pathway",
      "pillarverge pathway",
      "riverglide pathway",
      "lavaglide pathway",
    ]
  end

  def to_s
    "is:pathway"
  end
end

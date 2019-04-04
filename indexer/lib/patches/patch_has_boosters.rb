class PatchHasBoosters < Patch
  def call
    each_set do |set|
      booster = set.delete("booster") || set.delete("boosterV3")
      if set["code"] == "tsb" or set["code"] == "med"
        # https://github.com/mtgjson/mtgjson/issues/584
        has_own_boosters = false
      else
        has_own_boosters = !!booster
      end

      if set["code"] == "uma"
        has_own_boosters = true
      end

      included_in_other_boosters = %W[exp mps mp2 tsb].include?(set["code"])

      set["has_boosters"] = has_own_boosters || included_in_other_boosters
    end
  end
end

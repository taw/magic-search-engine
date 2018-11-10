class PatchHasBoosters < Patch
  def call
    each_set do |set|
      booster = set.delete("booster")
      if set["code"] == "tsb"
        # https://github.com/mtgjson/mtgjson/issues/584
        has_own_boosters = false
      else
        has_own_boosters = !!booster
      end

      included_in_other_boosters = %W[exp mps mps_akh tsb].include?(set["code"])

      set["has_boosters"] = has_own_boosters || included_in_other_boosters
    end
  end
end

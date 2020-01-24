class PatchHasBoosters < Patch
  def call
    each_set do |set|
      booster = set.delete("booster")
      if set["code"] == "tsb" or set["code"] == "med"
        # https://github.com/mtgjson/mtgjson/issues/584
        has_own_boosters = false
      else
        has_own_boosters = !!booster
      end

      # v4 bug?
      if %W[me1 nem mh1 p02 m20 eld thb].include?(set["code"])

        has_own_boosters = true
      end

      included_in_other_boosters = %W[exp mps mp2 tsb].include?(set["code"])

      set["has_boosters"] = !!has_own_boosters
      set["in_other_boosters"] = !!included_in_other_boosters
    end
  end
end

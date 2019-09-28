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
      if set["code"] == "me1" or set["code"] == "nem" or set["code"] == "mh1" or set["code"] == "p02" or set["code"] == "m20" or set["code"] == "eld"
        has_own_boosters = true
      end

      included_in_other_boosters = %W[exp mps mp2 tsb].include?(set["code"])

      set["has_boosters"] = !!has_own_boosters
      set["in_other_boosters"] = !!included_in_other_boosters
    end
  end
end

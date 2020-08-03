# This is really silly, as we're running the show now
# It is leftover from how it used to work in v3 / v4

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

      if %W[me1 nem mh1 p02 m20 eld thb mb1 cmb1 iko m21 2xm].include?(set["code"])
        has_own_boosters = true
      end

      included_in_other_boosters = %W[exp mps mp2 tsb fmb1].include?(set["code"])

      set["has_boosters"] = !!has_own_boosters
      set["in_other_boosters"] = !!included_in_other_boosters

      if set["code"] == "ala"
        set["booster_variants"] = {
          "premium" => "Alara Premium Foil Booster"
        }
      end
    end
  end
end

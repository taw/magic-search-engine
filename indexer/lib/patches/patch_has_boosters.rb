class PatchHasBoosters < Patch
  def call
    each_set do |set|
      booster = set.delete("booster")
      if set["code"] == "tsts"
        # https://github.com/mtgjson/mtgjson/issues/584
        set["has_boosters"] = false
      else
        set["has_boosters"] = !!booster
      end
    end
  end
end

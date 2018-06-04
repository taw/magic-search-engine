class PatchHasBoosters < Patch
  def call
    @sets.each do |set_code, set|
      booster = set.delete("booster")
      if set_code == "tsts"
        # https://github.com/mtgjson/mtgjson/issues/584
        set["has_boosters"] = false
      else
        set["has_boosters"] = !!booster
      end
    end
  end
end

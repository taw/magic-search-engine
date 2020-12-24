# This is really silly, as we're running the show now
# It is leftover from how it used to work in v3 / v4

class PatchHasBoosters < Patch
  # This just needs to list sets that didn't get to mtgjson yet
  def new_sets_with_boosters
    %W[znr cmr klr akr]
  end

  def call
    each_set do |set|
      booster = set.delete("booster")
      has_own_boosters = !!booster

      if new_sets_with_boosters.include?(set["code"])
        has_own_boosters = true
      end

      included_in_other_boosters = %W[exp mps mp2 tsb fmb1 plist].include?(set["code"])

      set["has_boosters"] = !!has_own_boosters
      set["in_other_boosters"] = !!included_in_other_boosters

      case set["code"]
      when "ala"
        set["booster_variants"] = {
          "premium" => "Alara Premium Foil Booster",
          "default" => nil,
        }
      when "klr", "akr"
        # Does not have normal boosters
        set["booster_variants"] = {
          "arena" => "#{set["name"]} Arena Booster",
        }
      else
        if has_own_boosters
          set["booster_variants"] = {
            "default" => nil,
          }
        else
          set["booster_variants"] = nil
        end
      end
    end
  end
end

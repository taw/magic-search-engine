# Data flow between this system and mtgjson is bidirectional
# - index says set has boosters if mtgjson says
# - mtgjson says so because old index said so
# - this is just an extra

class PatchHasBoosters < Patch
  # This just needs to list sets that didn't get to mtgjson yet
  def new_sets_with_boosters
    %W[
      sir
    ]
  end

  def arena_standard_sets
    %W[
      xln
      rix
      m19
      dom
      grn
      rna
      war
      m20
      eld
      thb
      iko
      m21
      znr
      khm
      stx
      afr
      mid
      vow
      neo
      snc
      dmu
      bro
      one
    ]
  end

  def included_in_other_boosters
    %W[
      exp
      mps
      mp2
      tsb
      fmb1
      plist
      sta
      sunf
      brr
      sis
    ]
  end

  def call
    each_set do |set|
      has_own_boosters = set.delete("has_boosters")

      if new_sets_with_boosters.include?(set["code"])
        if has_own_boosters
          warn "#{set["code"]} already has boosters, no need to include it in the patch list"
        else
          has_own_boosters = true
        end
      end

      set["has_boosters"] = !!has_own_boosters
      set["in_other_boosters"] = !!included_in_other_boosters.include?(set["code"])

      set_name = set["name"]

      case set["code"]
      when "ala"
        set["booster_variants"] = {
          "premium" => "Alara Premium Foil Booster",
          "default" => nil,
        }
      when "sir"
        set["booster_variants"] = {
          "arena-1" => "#{set_name} Arena Booster: Creature Type Terror",
          "arena-2" => "#{set_name} Arena Booster: Fatal Flashback",
          "arena-3" => "#{set_name} Arena Booster: Morbid And Macabre",
          "arena-4" => "#{set_name} Arena Booster: Abominable All Stars",
          "default" => nil,
        }
      when "klr", "akr"
        # Does not have normal boosters
        set["booster_variants"] = {
          "arena" => "#{set_name} Arena Booster",
        }
      when *arena_standard_sets
        # Also available on Arena
        set["booster_variants"] = {
          "arena" => "#{set["name"]} Arena Booster",
          "default" => nil,
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

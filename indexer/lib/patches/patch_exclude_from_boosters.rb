# Just for sets with boosters, some cards will be non-booster
# That's planeswalker deck exclusive cards,
# and also Firesong and Sunspeaker buy-a-box promo

class PatchExcludeFromBoosters < Patch
  def call
    each_printing do |card|
      set_code = card["set_code"]

      if sets_without_basics_in_boosters.include?(set_code) and card["supertypes"]&.include?("Basic")
        card["exclude_from_boosters"] = true
      end

      if exclude_from_boosters(set_code, card["number"])
        card["exclude_from_boosters"] = true
      end

      # They only have full art promos in boosters
      # Non full art are for precons
      #
      # in v4 non-booster version got -a suffix
      if %W[bfz ogw].include?(set_code) and
        card["supertypes"] == ["Basic"] and
        card["number"] =~ /a/
        card["exclude_from_boosters"] = true
      end

      # WAR are Japanese alt arts are in boosters,
      # just not in English boosters, so count them out
      #
      # Other star cards are foil alt arts and in boosters
      if card["number"] =~ /★/ and set_code == "war"
        card["exclude_from_boosters"] = true
      end

      # Mostly misprints and such
      if card["number"] =~ /†/ and (set_code != "arn" and set_code != "shm")
        card["exclude_from_boosters"] = true
      end
    end
  end

  # Based on http://www.lethe.xyz/mtg/collation/index.html
  # These sets do not have foils
  #
  # Many other sets had foil basics in boosters
  # but nonfoil basics only in other products
  # These do not belong here
  def sets_without_basics_in_boosters
    ["ice", "mir", "tmp", "usg", "4ed", "5ed", "6ed"]
  end

  def exclude_from_boosters(set_code, number)
    number_i = number.to_i

    case set_code
    when "m15"
      number_i > 269
    when "kld"
      number_i > 264
    when "aer"
      number_i > 184
    when "akh"
      number_i > 269
    when "hou"
      number_i > 199
    when "xln"
      number_i > 279
    when "rix"
      number_i > 196
    when "dom"
      number_i > 269
    when "ori"
      number_i > 272
    when "m19"
      number_i > 280
    when "grn", "rna"
      number_i > 259
    when "war"
      number_i > 264
    when "m20"
      number_i > 280
    when "eld"
      number_i > 269
    when "mh1"
      number_i > 254
    when "thb"
      number_i > 254
    when "iko"
      number_i > 274
    when "m21"
      # showcase basics actually in boosters
      number_i > 274 and not (309..313).include?(number_i)
    when "2xm"
      number_i > 332
    else
      false
    end
  end
end

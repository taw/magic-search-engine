# Just for sets with boosters, some cards will be non-booster
# That's planeswalker deck exclusive cards,
# and also Firesong and Sunspeaker buy-a-box promo

class PatchExcludeFromBoosters < Patch
  def call
    each_printing do |card|
      if exclude_from_boosters(card["set_code"], card["number"])
        card["exclude_from_boosters"] = true
      end

      # They only have full art promos in boosters
      # Non full art are for precons
      #
      # in v4 non-booster version got -a suffix
      if %W[bfz ogw].include?(card["set_code"]) and
        card["supertypes"] == ["Basic"] and
        card["number"] =~ /a/
        card["exclude_from_boosters"] = true
      end

      # WAR are Japanese alt arts are in boosters,
      # just not in English boosters, so count them out
      #
      # Other star cards are foil alt arts and in boosters
      if card["number"] =~ /★/ and card["set_code"] == "war"
        card["exclude_from_boosters"] = true
      end

      # Mostly misprints and such
      if card["number"] =~ /†/ and card["set_code"] != "arn"
        card["exclude_from_boosters"] = true
      end
    end
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
    else
      false
    end
  end
end

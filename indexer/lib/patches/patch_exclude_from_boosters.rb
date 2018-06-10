# Just for sets with boosters, some cards will be non-booster
# That's planeswalker deck exclusive cards,
# and also Firesong and Sunspeaker buy-a-box promo

class PatchExcludeFromBoosters < Patch
  def call
    each_printing do |card|
      if exclude_from_boosters(card["set_code"], card["number"].to_i)
        card["exclude_from_boosters"] = true
      end
      # They only have full art promos in boosters
      # Non full art are for precons
      # (we arbitrarily append A to full art versions)
      if %W[bfz ogw].include?(card["set_code"]) and
        card["supertypes"] == ["Basic"] and
        card["number"] !~ /A/
        card["exclude_from_boosters"] = true
      end
    end
  end

  def exclude_from_boosters(set_code, number)
    case set_code
    when "kld"
      number > 264
    when "aer"
      number > 184
    when "akh"
      number > 269
    when "hou"
      number > 199
    when "xln"
      number > 279
    when "rix"
      number > 196
    when "dom"
      number > 269
    when "ori"
      number > 272
    else
      false
    end
  end
end

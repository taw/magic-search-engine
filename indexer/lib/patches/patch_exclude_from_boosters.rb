# Just for sets with boosters, some cards will be non-booster
# That's planeswalker deck exclusive cards,
# and also Firesong and Sunspeaker buy-a-box promo

class PatchExcludeFromBoosters < Patch
  def call
    each_printing do |card|
      set_code = card["set_code"]
      set = card["set"]

      # No point writing rules for these, even if they have some kind of base set size
      next unless set["has_boosters"] or set["in_other_boosters"]

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

      # Mostly Chinese non-skeleton versions
      if card["number"] =~ /s/i and ["por", "usg", "inv", "pcy", "5ed", "6ed", "7ed", "8ed", "9ed"].include?(set_code)
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
    set = set_by_code(set_code)
    # We need to patch this for a few sets
    base_size = set["base_set_size"]

    case set_code
    when "afr"
      number_i > base_size or number =~ /★/
    when "sta"
      # incorrect in mtgjson
      number_i > 63 or number =~ /e/
    when "m21"
      # showcase basics actually in boosters
      number_i > base_size and not (309..313).include?(number_i)
    when "bro"
      # only special basics in boosters
      # normal boosters are in printed range, but not actually in boosters
      number_i > base_size or (268..277).include?(number_i)
    when "stx", "gpt"
      number_i > base_size or number =~ /★/
    when "por"
      number_i > base_size or number =~ /d/
    when "iko"
      # borderless planeswalkers are numbered #276-278
      # showcase cards are numbered #279-313
      # extended artwork cards are numbered #314-363 - these are just collector boosters
      ![1..274, 276..278, 279..313].any?{|r| r.include?(number_i)}
    when "dmr"
      # retro basics included
      number_i > base_size and not (402..411).include?(number_i)
    when "mb1"
      number_i >= 1695 or number =~ /†/
    when "zen"
      # non-fullart basics are excluded
      number =~ /a/
    when "plist"
      # not sure what to do with this, it's not in draft boosters?
      false
    when "bbd", "cn2", "unh"
      # have over-set-size cards in boosters
      false
    else
      # Default is to exclude everything beyond base size
      if base_size
        number_i > base_size
      else
        false
      end
    end
  end
end

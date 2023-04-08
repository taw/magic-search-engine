# Just for sets with boosters, some cards will be non-booster
# That's planeswalker deck exclusive cards,
# and also Firesong and Sunspeaker buy-a-box promo

class PatchExcludeFromBoosters < Patch
  def call
    each_printing do |card|
      set_code = card["set_code"]
      set = card["set"]
      base_size = set["base_set_size"] # We need to patch this for a few sets
      number = card["number"]
      number_i = number.to_i

      # No point writing rules for these, even if they have some kind of base set size
      next unless set["has_boosters"] or set["in_other_boosters"]

      if base_size and (number_i > base_size or number_i < 1)
        unless include_beyond_base_size(set_code, card["number"])
          card["exclude_from_boosters"] = true
        end
      end

      if card["variant_foreign"] or card["variant_misprint"]
        card["exclude_from_boosters"] = true
      end

      if exclude_from_boosters(set_code, card["number"])
        card["exclude_from_boosters"] = true
      end

      if sets_without_basics_in_boosters.include?(set_code) and card["supertypes"]&.include?("Basic")
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

  def include_beyond_base_size(set_code, number)
    number_i = number.to_i

    case set_code
    when "plist"
      # not sure what to do with this, it's not in draft boosters?
      true
    when "bbd", "cn2", "unh"
      # have over-set-size cards in boosters
      true
    when "m21"
      # showcase basics actually in boosters
      (309..313).include?(number_i)
    when "dmr"
      # retro basics included
      (402..411).include?(number_i)
    when "mb1"
      number_i < 1695
    when "iko"
      # borderless planeswalkers are numbered #276-278
      # showcase cards are numbered #279-313
      # extended artwork cards are numbered #314-363 - these are just collector boosters
      [276..278, 279..313].any?{|r| r.include?(number_i)}
    when "unf"
      (277..286).include?(number_i) # shock lands can appear in draft boosters
    else
      false
    end
  end

  def exclude_from_boosters(set_code, number)
    number_i = number.to_i
    set = set_by_code(set_code)

    case set_code
    when "sta"
      # incorrect in mtgjson
      number_i > 63 or number =~ /e/
    when "bro"
      # only special basics in boosters
      # normal boosters are in printed range, but not actually in boosters
      (268..277).include?(number_i)
    when "por"
      # it also has S variants
      number =~ /d/
    when "zen"
      # non-fullart basics are excluded
      number =~ /a/
    when "brr"
      number =~ /z/
    else
      # Default is to exclude everything beyond base size
      false
    end
  end
end

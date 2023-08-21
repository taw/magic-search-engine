# This is for foreign variants with different art that are not included in English boosters
# This is not meant for intentional foreign promos
class PatchVariantForeign < Patch
  def call
    each_printing do |card|
      card["variant_foreign"] = true if is_variant_foreign?(card)
    end
  end

  def is_variant_foreign?(card)
    number = card["number"]
    number_i = number.to_i
    case card["set_code"]
    when "usg", "inv", "pcy", "5ed", "6ed", "7ed", "8ed", "9ed", "10e", "por"
      # Chinese non-skeleton versions
      # Regexp should match "289sb" but not "S1"
      number =~ /.s/i
    when "war"
      # WAR are Japanese alt arts are in boosters,
      # just not in English boosters, so count them out
      #
      # Other star cards are foil alt arts and in boosters
      number =~ /★/
    when "iko"
      # Numbers already outside range, so booster code doesn't need it, but it logically makes sense to tag it:
      number_i >= 385 and number_i <= 387
    when "sta"
      # Numbers already outside range, so booster code doesn't need it, but it logically makes sense to tag it:
      number_i >= 64 and number_i <= 126
    end
  end
end

class PatchVariantMisprint < Patch
  def call
    each_printing do |card|
      card["variant_misprint"] = true if is_variant_misprint?(card)
    end
  end

  def is_variant_misprint?(card)
    number = card["number"]
    case card["set_code"]
    when "arn"
      # ARN has both in boosters https://www.lethe.xyz/mtg/collation/arn.html
      false
    when "gpt", "stx"
      number =~ /★/
    when "inv"
      # This is some promo, should be in PINV not INV
      number =~ /★/
    else
      number =~ /†/
    end
  end
end

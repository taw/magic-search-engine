# Which finishes each printing came in. mtgjson works that out for us, so this
# is a translation and a couple of fixes rather than a calculation.

class PatchFoiling < Patch
  # mtgjson's finishes we model, in IndexFormat::FINISH_BITS order. The one it
  # has that we don't is `signed`, which is an autograph on an ordinary card,
  # not a finish of its own.
  FINISHES = %W[nonfoil foil etched].freeze
  DEFAULT = %W[nonfoil foil].freeze

  def call
    each_printing do |card|
      # Someone should investigate if this is true
      # This also applies to PSOI
      if card["name"] == "Tamiyo's Journal" and card["set_code"] == "soi"
        card["finishes"] = DEFAULT
        next
      end
      finishes = FINISHES & card["finishes"]
      # A handful of cards mtgjson lists no finish at all for
      finishes = DEFAULT if finishes.empty?
      card["finishes"] = finishes
    end

    # And now fix foiling errors in mtgjson
    each_printing do |card|
      next if card["alchemy"]

      case card["set_code"]
      # There are two suspicious cards in INV inv/124★ and inv/134★ but I can't find which product they're even from
      # so I disabled attempts at fixing them.
      # when "inv"
      #   fix_to card, %W[nonfoil foil]
      when "tsr"
        if card["number"] == "411"
          # I think?
          fix_to card, %W[foil]
        end
      end
    end
  end

  def fix_to(card, fixed)
    return if card["finishes"] == fixed
    warn "Fixing finishes of #{card["name"]} [#{card["set_code"]}/#{card["number"]}] to #{fixed.join(", ")}"
    card["finishes"] = fixed
  end
end

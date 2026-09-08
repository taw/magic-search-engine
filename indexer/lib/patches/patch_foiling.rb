# Which finishes each printing came in. mtgjson works that out for us, so this
# is a translation rather than a calculation.

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
  end
end

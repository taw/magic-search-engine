# Nissa loyalty https://github.com/mtgjson/mtgjson/issues/419
# https://github.com/mtgjson/mtgjson/issues/320
class PatchNissa < Patch
  def call
    each_printing do |card|
      next unless card["name"] == "Nissa, Steward of Elements"
      card["loyalty"]  = "X"
    end
  end
end

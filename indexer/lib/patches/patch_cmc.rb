# Lands in UGL/UNH/UST have no cmc
# This looks like issue with us using older version, not with current mtgjson
class PatchCmc < Patch
  def call
    each_printing do |card|
      card["cmc"] ||= 0
    end
  end
end

# Lands in UG/UH/UST have no cmc
# This looks like issue with us using older version, not with current mtgjson
class PatchCmc < Patch
  def call
    patch_card do |card|
      card["cmc"] ||= 0
    end
  end
end

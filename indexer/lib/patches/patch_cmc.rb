# mtgjson error: some lands nil cmc [TODO: report a ticket]
class PatchCmc < Patch
  def call
    patch_card do |card|
      card["cmc"] ||= 0
    end
  end
end

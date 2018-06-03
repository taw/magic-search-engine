# https://github.com/mtgjson/mtgjson/issues/577
class PatchSaga < Patch
  def call
    patch_card do |card|
      subtypes = card["subtypes"] || []
      next unless subtypes.include?("Saga")
      card["layout"] = "saga"
    end
  end
end

class PatchMB1 < Patch
  def call
    # mtgjson should do it at some point
    # Remove all cards
    delete_printing_if do |card|
      card["set_code"] == "mb1"
    end
  end
end

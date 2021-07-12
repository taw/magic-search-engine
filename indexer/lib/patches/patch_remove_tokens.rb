# mtgjson moved them to a separate data structure so this doesn't do anything
# anymore unless they mess up

class PatchRemoveTokens < Patch
  def call
    delete_printing_if do |printing|
      printing["layout"] == "token" or printing["name"] == "Double-Faced Substitute Card"
    end
  end
end

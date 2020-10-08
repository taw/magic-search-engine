# We currently don't use information about tokens so don't keep it in the index
class PatchRemoveTokens < Patch
  def call
    delete_printing_if do |printing|
      printing["layout"] == "token" or printing["name"] == "Double-Faced Substitute Card"
    end
  end
end

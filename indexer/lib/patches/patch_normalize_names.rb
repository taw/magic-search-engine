class PatchNormalizeNames < Patch
  def call
    patch_card do |card|
      next unless card["names"]
      card["names"] = card["names"].sort
    end
  end
end

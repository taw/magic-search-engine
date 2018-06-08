class PatchNormalizeNames < Patch
  def call
    each_printing do |card|
      next unless card["names"]
      card["names"] = card["names"].sort
    end
  end
end

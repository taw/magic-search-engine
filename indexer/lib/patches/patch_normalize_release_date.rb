class PatchNormalizeReleaseDate < Patch
  def call
    patch_card do |card|
      release_date = card.delete("releaseDate") or next
      card["release_date"] = Indexer.format_release_date(release_date)
    end
  end
end

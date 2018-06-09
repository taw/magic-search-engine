class PatchNormalizeReleaseDate < Patch
  def call
    each_printing do |card|
      release_date = card.delete("releaseDate") or next
      card["release_date"] = normalize_release_date(release_date)
    end

    each_set do |set|
      release_date = set.delete("releaseDate") or next
      set["release_date"] = normalize_release_date(release_date)
    end
  end

  def normalize_release_date(date)
    return nil unless date
    case date
    when /\A\d{4}-\d{2}-\d{2}\z/
      date
    when /\A\d{4}-\d{2}\z/
      "#{date}-01"
    when /\A\d{4}\z/
      "#{date}-01-01"
    else
      raise "Release date format error: #{date}"
    end
  end
end

class ConditionArtist < ConditionSimple
  def initialize(artist)
    @artist = artist.downcase
    artist_normalized = @artist.normalize_accents
    @artist_rx = Regexp.new("\\b(?:" + Regexp.escape(artist_normalized) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    card.artist_name =~ @artist_rx
  end

  def to_s
    "a:#{maybe_quote(@artist)}"
  end
end

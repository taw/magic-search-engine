class ConditionArtistRegexp < ConditionRegexp
  def match?(card)
    card.artist_name =~ @regexp
  end

  def to_s
    "a:#{@regexp.inspect.sub(/[im]+\z/, "")}"
  end

  private

  def field_description
    "the artist credit"
  end
end

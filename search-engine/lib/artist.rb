class Artist
  attr_reader :name, :slug
  attr_accessor :printings
  # Set by CardDatabase initialization, artists ordered by downcased name
  attr_accessor :sort_index

  def initialize(name)
    @name = name
    @slug = name.downcase.gsub(/[^a-z0-9\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/, "_")
    @printings = []
  end

  include Comparable

  def <=>(other)
    sort_index <=> other.sort_index
  end
end

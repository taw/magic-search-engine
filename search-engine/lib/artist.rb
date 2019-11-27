class Artist
  attr_reader :name, :slug
  attr_accessor :printings

  def initialize(name)
    @name = name
    @slug = name.downcase.gsub(/[^a-z0-9\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/, "_")
    @printings = Set[]
  end

  include Comparable

  def <=>(other)
    @name <=> other.name
  end
end

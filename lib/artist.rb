class Artist
  attr_reader :name, :slug
  attr_accessor :printings

  def initialize(name)
    @name = name
    @slug = name.downcase.gsub(/[^a-z]+/, "_")
    @printings = Set[]
  end
end

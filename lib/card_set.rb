class CardSet
  attr_reader :set_name, :set_code, :block_name, :block_code, :border, :release_date
  def initialize(data)
    @set_name     = data["set_name"]
    @set_code     = data["set_code"]
    @block_name   = data["block_name"]
    @block_code   = data["block_code"]
    @border       = data["border"]
    @release_date = data["releaseDate"]
  end

  include Comparable
  def <=>(other)
    set_code <=> other.set_code
  end
end

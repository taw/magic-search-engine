class UnknownCard
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(other)
    other.is_a?(UnknownCard) and name == other.name
  end

  def hash
    name.hash
  end

  def eql?(other)
    self == other
  end
end

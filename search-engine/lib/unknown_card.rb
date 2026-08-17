class UnknownCard
  attr_reader :name

  # We know nothing about it, so it can't go into any of Card's groups,
  # and it sorts after all of them
  TYPE_GROUP = [9, "Other"].freeze

  def initialize(name)
    @name = name
  end

  def type_group
    TYPE_GROUP
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

  def inspect
    "UnknownCard[#{@name}]"
  end
end

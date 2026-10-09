# Tokens selected by an explicit token-set/number, outside the searchable card
# index. The existing token UUID index is also used by the deck exporter.
class BoosterToken
  include Comparable
  attr_reader :set_code, :number, :uuid, :name, :finish, :parent_set_code

  def initialize(parent_set_code, set_code, number, uuid, name, finish, index)
    @parent_set_code = parent_set_code
    @set_code, @number, @uuid, @name, @finish = set_code, number, uuid, name, finish
    @sort_key = -1 - index * PhysicalCard::FINISHES.size - PhysicalCard::FINISHES.index(finish)
  end

  attr_reader :sort_key
  def <=>(other)
    sort_key <=> other.sort_key
  end

  def ==(other)
    other.is_a?(BoosterToken) && [set_code, number, finish] == [other.set_code, other.number, other.finish]
  end
  alias eql? ==

  def hash
    [set_code, number, finish].hash
  end

  def foil
    finish != :nonfoil
  end

  def etched
    finish == :etched
  end

  # Availability scans can include tokens, but there are no searchable faces
  # on which to set in_boosters flags.
  def main_front
    self
  end

  def parts
    []
  end
end

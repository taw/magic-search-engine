class Product
  attr_reader :name

  def initialize(set, data)
    @set = set
    @name = data["name"]
  end
end

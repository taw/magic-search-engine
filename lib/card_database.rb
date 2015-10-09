require "pathname"
require "json"

class CardDatabase
  attr_reader :data
  def initialize(path)
    @path = Pathname(path)
    @data = JSON.parse(@path.open.read)
  end

  def search(query)
    []
  end
end

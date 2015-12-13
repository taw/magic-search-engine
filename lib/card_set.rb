class CardSet
  attr_reader :name, :code, :gatherer_code
  attr_reader :block_name, :block_code
  attr_reader :border, :release_date, :printings, :type
  def initialize(data)
    @name          = data["name"]
    @code          = data["code"]
    @gatherer_code = data["gatherer_code"]
    @block_name    = data["block_name"]
    @block_code    = data["block_code"] && data["block_code"].downcase
    @border        = data["border"]
    @type          = data["type"]
    @release_date  = data["release_date"] && Date.parse(data["release_date"])
    @printings     = Set[]
  end

  def regular?
    @type == "core" or @type == "expansion"
  end

  include Comparable
  def <=>(other)
    @code <=> other.code
  end

  def hash
    @set_code.hash
  end
end

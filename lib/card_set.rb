class CardSet
  def initialize(data)
    @data = data
  end

  def method_missing(m)
    if @data.has_key?(m.to_s)
      @data[m.to_s]
    else
      super
    end
  end
end

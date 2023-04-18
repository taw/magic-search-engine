class ConditionLight < ConditionSimple
  def initialize(light)
    if light == "*"
      @light = "*"
    else
      @light = light.to_i
    end
  end

  def match?(card)
    return false unless card.attraction_lights
    if @light == "*"
      true
    else
      card.attraction_lights.include?(@light)
    end
  end

  def to_s
    "light:#{@light}"
  end
end

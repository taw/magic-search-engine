class ConditionLight < ConditionSimple
  def initialize(light)
    @any = (light == "*")
    if @any
      @light = "*"
    else
      @light = light.to_i
    end
  end

  def match?(card)
    return false unless card.attraction_lights
    if @any
      true
    else
      card.attraction_lights.include?(@light)
    end
  end

  def to_s
    "light:#{@light}"
  end
end

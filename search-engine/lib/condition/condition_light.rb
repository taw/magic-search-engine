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

  def explain
    @any ? "the card has an attraction light" : "the card has attraction light #{@light}"
  end
end

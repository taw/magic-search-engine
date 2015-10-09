class Query
  def initialize(query)
    @query = query.strip
  end

  def matches?(card)
    case @query
    when /\Ac:(.*)\z/i
      matches_colors?(card, $1.downcase)
    when /\Ac!(.*)\z/i
      matches_colors_exact?(card, $1.downcase)
    when /\At:(.*?)\z/i
      card.types.include?($1.downcase)
    when /\A!(.*)\z/i
      normalize_name(card.name) == normalize_name($1)
    when /\A[^:!]+\z/i
      @query.split.all? do |word|
        card.name.split.include?(word)
      end
    else
      raise "Query error: #{@query}"
    end
  end

private

  def normalize_name(name)
    name.downcase.strip.split.join(" ")
  end

  def matches_colors?(card, colors_query)
    colors = card.colors
    colors_query.chars.any? do |q|
      case q
      when "w"
        colors.include?("White")
      when "u"
        colors.include?("Blue")
      when "b"
        colors.include?("Black")
      when "r"
        colors.include?("Red")
      when "g"
        colors.include?("Green")
      when "m"
        colors.size >= 2
      when "c"
        colors.size == 0
      end
    end
  end

  def matches_colors_exact?(card, colors_query)
    return false unless matches_colors?(card, colors_query)
    return false if card.colors.include?("White") and colors_query !~ /w/
    return false if card.colors.include?("Blue") and colors_query !~ /u/
    return false if card.colors.include?("Black") and colors_query !~ /b/
    return false if card.colors.include?("Red") and colors_query !~ /r/
    return false if card.colors.include?("Green") and colors_query !~ /g/
    true
  end
end

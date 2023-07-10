class PatchDeckLimit < Patch
  def call
    # Officially JSON doesn't support infinity
    each_printing do |printing|
      if printing["supertypes"]&.include?("Basic")
        printing["decklimit"] = "any"
      end

      next unless printing["text"] =~ /A deck can have/

      case printing["text"]
      when /A deck can have only one card named/
        printing["decklimit"] = 1
      when /A deck can have up to seven cards named/
        printing["decklimit"] = 7
      when /A deck can have up to nine cards named/
        printing["decklimit"] = 9
      when /A deck can have any number of cards named/
        printing["decklimit"] = "any"
      else
        warn "Failed to parse deck limit: #{printing["text"]}"
      end
    end
  end
end

require "unicode_utils"

class ForeignNamesVerifier
  def initialize
    @raw_data = {}
  end

  def language_name_to_code
    @language_name_to_code ||= {
      "Chinese Simplified"  => "cs",
      "Chinese Traditional" => "ct",
      "French"              => "fr",
      "German"              => "de",
      "Italian"             => "it",
      "Japanese"            => "jp",
      "Korean"              => "kr",
      "Portuguese (Brazil)" => "pt",
      "Russian"             => "ru",
      "Spanish"             => "sp",
    }
  end

  def add(card_name, set_code, foreign_names_data)
    return unless foreign_names_data
    @raw_data[card_name] ||= {}
    foreign_names_data.each do |e|
      language_code = language_name_to_code.fetch(e["language"])
      foreign_name = e["name"].gsub("&nbsp;", " ")
      next if foreign_name == ""
      @raw_data[card_name][language_code] ||= {}
      @raw_data[card_name][language_code][foreign_name] ||= []
      @raw_data[card_name][language_code][foreign_name] << set_code
    end
  end

  def verify!
    @data = {}
    @raw_data.each do |card_name, foreign_names|
      @data[card_name] = {}
      foreign_names.each do |language_code, names|
        if names.size == 1
          foreign_names = [names.keys[0]]
        elsif names.size == 2 and names.include?(card_name)
          # English names are often mistakenly listed by Gatherer
          foreign_names = [(names.keys - [card_name])[0]]
        elsif names.keys.map{|s| UnicodeUtils.upcase(s)}.uniq.size == 1
          # If names differ only by capitalization, take the most capitalized name
          foreign_names = [names.keys.max_by{|s|
            s.chars.count{|c| UnicodeUtils.upcase(c) == c}
          }]
        elsif names.keys.any?{|n| n =~ /\(/}
          # Pointless A (A/B) for split cards
          short_names = names.keys.map{|x| x.sub(/\s*\(.*\)\z/, "")}.uniq
          raise unless short_names.size == 1
          foreign_names = [short_names[0]]
        else
          # No idea, just include them all
          # That's 137 cards right now
          foreign_names = names.keys
        end
        @data[card_name][language_code] = foreign_names
      end
    end
  end

  def foreign_names(card_name)
    @data[card_name]
  end
end

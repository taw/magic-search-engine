# This is needed by old ruby versions, we can probably get rid of that and just require minimum version
require "unicode_utils"

class PatchReconcileForeignNames < Patch
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

  def call
    each_card do |name, printings|
      ### Extract raw data
      # delete foreignNames while we're at it
      raw_data = extract_raw_data(printings)

      ### Reconcile data
      reconciled_data = reconcile(name, raw_data)

      ### Assign to all printings
      unless reconciled_data.empty?
        printings.each do |printing|
          printing["foreign_names"] = reconciled_data
        end
      end
    end
  end

  def extract_raw_data(printings)
    raw_data = {}
    printings.each do |printing|
      set_code = printing["set_code"]
      foreign_names_data = printing.delete("foreignNames") || printing.delete("foreignData") || next
      foreign_names_data.each do |e|
        language_code = language_name_to_code.fetch(e["language"])
        foreign_name = e["name"].gsub("&nbsp;", " ").gsub("\u00a0", " ").sub(/ —\z/, "")
        next if foreign_name == ""
        raw_data[language_code] ||= {}
        raw_data[language_code][foreign_name] ||= []
        raw_data[language_code][foreign_name] << set_code
      end
    end
    raw_data
  end

  def reconcile(card_name, raw_data)
    result = {}

    raw_data.each do |language_code, names|
      result[language_code] = begin
        if names.size == 1
          [names.keys[0]]
        elsif names.size == 2 and names.include?(card_name)
          # English names are often mistakenly listed by Gatherer
          [(names.keys - [card_name])[0]]
        elsif names.keys.map{|s| UnicodeUtils.upcase(s)}.uniq.size == 1
          # If names differ only by capitalization, take the most capitalized name
          [names.keys.max_by{|s|
            s.chars.count{|c| UnicodeUtils.upcase(c) == c}
          }]
        elsif names.keys.any?{|n| n =~ /\(/}
          # Pointless A (A/B) for split cards
          short_names = names.keys.map{|x| x.sub(/\s*\(.*\)\z/, "")}.uniq
          raise unless short_names.size == 1
          [short_names[0]]
        else
          # No idea, just include them all
          # That's 137 cards right now
          names.keys
        end
      end
    end

    result
  end
end

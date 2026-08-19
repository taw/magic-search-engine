# Text formatting fixes, applied to every printing.
# Nothing here is card-specific - if you need to fix one card, fix it elsewhere.

class PatchTextCleanup < Patch
  def call
    each_printing do |card|
      card["text"] = cleanup_text(card["text"]) if card["text"]
      card["artist"] = cleanup_unicode_punctuation(card["artist"]) if card["artist"]
      card["flavor"] = cleanup_flavor(card["flavor"]) if card["flavor"]
      card["rulings"]&.each do |ruling|
        ruling["text"] = cleanup_unicode_punctuation(ruling["text"])
      end
    end
  end

  private

  def cleanup_unicode_punctuation(text)
    text.tr(%[‘’“”], %[''""])
  end

  def cleanup_text(text)
    text = cleanup_unicode_punctuation(text)
    # Weird Escape formatting, make it match other similar abilities
    text = text.gsub(/^Escape—/, "Escape — ")
    text
  end

  def cleanup_flavor(flavor)
    # mtgjson drops the newline before the attribution line
    flavor = flavor.gsub(%[" —], %["\n—]).gsub(%[" "], %["\n"])
    # mtgjson started using * to indicate italics? annoying
    flavor = flavor.delete("*")
    # Old flavor text spells out ligatures that no other field uses
    flavor = flavor.gsub("Æ", "Ae").gsub("æ", "ae")
    flavor
  end
end

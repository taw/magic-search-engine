# Arena sometimes uses different art from paper version
#
# This is unrelated to is:alchemy, Omenpath etc.
class PatchVariantArena < Patch
  def call
    cards_by_set.each do |set_code, printings|
      # Arena-only sets are not variants of anything
      next unless printings.any?{|card| card["paper"]}
      printings.each do |card|
        next if card["alchemy"]
        next unless card["arena"] and !card["paper"] and !card["mtgo"]
        card["variant_arena"] = true
      end
    end
  end
end

# CR 700.2: a spell or ability is modal if it has two or more options in a bulleted
# list preceded by instructions for a player to choose a number of those options.
#
# Spree and tiered spells are modal as well (CR 702.172a, 702.183a), but the only
# place either card says so is reminder text, and spree marks its modes with "+"
# rather than bullets - so those two come from the keyword instead.
class PatchIsModal < Patch
  Keywords = %W[spree tiered].to_set

  BulletedModes = /(choose|opponent chooses) .*\n•/im

  # Pawprint cards (CR 107.18) and their funny cousins print each mode behind the
  # symbol it costs instead of a bullet, so the list is only recognizable from the
  # instruction above it. Requiring the next line to start a list is what keeps out
  # the cards that merely talk about modes, like Far Out and Chira, All In.
  CountedModes = /(choose|chooses)[^\n]*\bmodes?\b[^\n]*\n(?=[•\[{♦])/i

  def call
    each_printing do |printing|
      printing["is_modal"] = true if modal?(printing)
    end
  end

  private

  def modal?(printing)
    return true if printing["keywords"]&.any?{|keyword| Keywords.include?(keyword)}
    text = printing["text"] or return false
    text =~ BulletedModes or text =~ CountedModes
  end
end

# CR 700.2: a spell or ability is modal if it has two or more options in a bulleted
# list preceded by instructions for a player to choose a number of those options.
#
# Spree and tiered spells are modal as well (CR 702.172a, 702.183a), but the only
# place either card says so is reminder text, and spree marks its modes with "+"
# rather than bullets - so those two come from the keyword instead.
class PatchIsModal < Patch
  Keywords = %W[spree tiered].to_set

  def call
    each_printing do |printing|
      printing["is_modal"] = true if modal?(printing)
    end
  end

  private

  def modal?(printing)
    return true if printing["keywords"]&.any?{|keyword| Keywords.include?(keyword)}
    printing["text"] =~ /(choose|opponent chooses) .*\n•/im
  end
end

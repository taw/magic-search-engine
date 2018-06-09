class PatchMeldCardNames < Patch
  # Unfortunately mtgjson changed its mind,
  # and there's no way to distinguish front and back side of melded cards
  def call
    melded_cards = [
      "Brisela, Voice of Nightmares",
      "Hanweir, the Writhing Township",
      "Chittering Host",
    ]
    melded_cards.each do |melded|
      part_names = @cards[melded][0]["names"] - [melded]
      part_names.each do |part_name|
        @cards[part_name].each do |part_printing|
          part_printing["names"] -= (part_names - [part_name])
        end
      end
    end
  end
end

describe Deck do
  include_context "db"

  DisplayCommanderSets = {
    "ocmd" => "cmd",
    "oc13" => "c13",
    "oc14" => "c14",
    "oc15" => "c15",
    "oc16" => "c16",
    "oc17" => "c17",
    "oc18" => "c18",
    "oc19" => "c19",
    "oc20" => "c20",
    "oc21" => "c21",
  }

  DisplayCommanderSets.each do |oversize_set_code, normal_set_code|
    it "#{normal_set_code} has all display commanders from #{oversize_set_code}" do
      oversized_cards = db.sets[oversize_set_code].printings
      decks = db.sets[normal_set_code].decks

      decks.each do |deck|
        card_names = (deck.section("Main Deck") + deck.section("Commander")).map(&:last).map(&:name).to_set
        expected_oversized_cards = oversized_cards.select{|c| card_names.include?(c.name) }
        actual_oversized_cards = deck.section("Display Commander").map(&:last).map(&:name)
        expected_oversized_cards.each do |expected_card|
          actual_oversized_cards.should(include(expected_card.name), "Deck #{deck.set_code} #{deck.name} should contain display commander #{expected_card.name} [#{oversize_set_code}]")
        end
      end

      # One more check just in case oversized card does not correspond to non-oversized card
      actual_display_commanders = decks.flat_map{|d| d.section("Display Commander") }.map(&:last).map(&:name)
      oversized_cards.map(&:name).should match_array(actual_display_commanders)
    end
  end
end

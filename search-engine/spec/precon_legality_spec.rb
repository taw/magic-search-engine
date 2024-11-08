describe Deck do
  include_context "db"

  let(:decks_to_check) { db.decks.select{|d| d.category != "box" } }

  # it's especially non-obvious if a product is "standard" or "casual"
  it "categorizes format correctly" do
    decks_to_check.group_by(&:format).each do |format, decks|
      decks.each do |deck|
        case format
        when "jumpstart", "shandalar", "planechase", "archenemy", "planechase commander", "arena", "archenemy commander"
          # no risk of accidentally tagging them wrong
        when "casual", "historic brawl"
          verify_deck_is_casual(deck)
        when "commander", "modern", "standard", "brawl", "pioneer", "standard", "casual standard"
          verify_deck_is_legal(deck)
        else
          warn "Unrecognized format #{deck.format}"
        end
      end
    end
  end

  def verify_deck_is_casual(deck)
    # Early tournaments often had special near-Standard formats we do not really support
    # Some decks can end up accidentally Standard legal
    accidentally_legal_decks = [
      ["ptc", "George Baxter, Quarterfinalist"],
      ["ptc", "Leon Lindback, Semifinalist"],
    ]

    check = format_check(deck)

    if accidentally_legal_decks.include?([deck.set_code, deck.name])
      check.should(eq(true), "#{deck.set_code} #{deck.name} should be #{deck.format} legal (as known exception)")
    else
      check.should(eq(false), "#{deck.set_code} #{deck.name} should be casual")
    end
  end

  def verify_deck_is_legal(deck)
    known_illegal_decks = [
      ["uds", "Enchanter - Enhanced Deck"],
      ["uds", "Fiendish Nature - Enhanced Deck"],
      ["q07", "Mono White Aggro"],
      ["q08", "Izzet Phoenix"],
    ]

    check = format_check(deck)

    if known_illegal_decks.include?([deck.set_code, deck.name])
      check.should(eq(false), "#{deck.set_code} #{deck.name} should be #{deck.format} illegal (as known exception)")
    else
      check.should(eq(true), "#{deck.set_code} #{deck.name} should be #{deck.format} legal")
      unless check
        illegal_cards(deck).each do |card|
          puts "* #{card}"
        end
      end
    end
  end

  def format_check(deck)
    illegal_cards(deck).empty?
  end

  def illegal_cards(deck)
    all_cards = deck.all_cards.map(&:last).uniq
    format = format_for(deck)
    all_cards.reject{|c| format.legal?(c.main_front)}
  end

  def format_for(deck)
    date = deck.release_date
    # Unplanned covid related release mess, IKO card became legal for Commander one week before their IKO printings
    # https://magic.wizards.com/en/news/feature/ikoria-lair-behemoths-and-commander-2020-edition-release-notes-2020-04-10
    date = Date.parse("2020-04-24") if deck.set_code == "c20"
    # Intentional pre-print of Amonkhet cards two weeks early
    date = Date.parse("2017-04-28") if deck.set_code == "w17"

    case deck.format
    when "commander"
      FormatCommander.new(date)
    when "modern"
      FormatModern.new(date)
    when "brawl"
      FormatBrawl.new(date)
    when "pioneer"
      FormatPioneer.new(date)
    else
      FormatStandard.new(date)
    end
  end
end

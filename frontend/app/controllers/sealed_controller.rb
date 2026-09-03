class SealedController < ApplicationController
  # No real sealed event opens this many, and counts come straight out of the
  # url, where they were once big enough to exhaust the server's memory
  MAX_PACKS = 1000
  # Capped rows still add up, so the pool as a whole gets a deadline
  PACK_OPENING_TIME_LIMIT = 5.0

  # Controller supports >3 pack types
  def index
    requested_counts = Array(params[:count]).map(&:to_i)
    counts = requested_counts.map{|count| count.clamp(0, MAX_PACKS)}
    set_codes = Array(params[:set])
    @fixed = params[:fixed]
    fixed_cards = FixedCardList.new($CardDatabase, params[:fixed])
    @warnings = fixed_cards.warnings
    if counts != requested_counts
      @warnings += ["At most #{MAX_PACKS} packs per row, ignoring the rest"]
    end

    @packs_to_open = set_codes.zip(counts)
    packs_requested = !@packs_to_open.empty?

    @booster_types = $CardDatabase.supported_booster_types

    # Links from limited format pages can ask for fewer than 3 pack types,
    # and the empty rows still need something selected
    most_recent_booster_type = $CardDatabase.most_recent_booster_type
    if @packs_to_open.empty?
      @packs_to_open << [most_recent_booster_type, 6]
    end
    @packs_to_open << [most_recent_booster_type, 0] while @packs_to_open.size < 3

    @booster_options = booster_options

    if packs_requested
      @cards = fixed_cards.cards.dup
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + PACK_OPENING_TIME_LIMIT
      out_of_time = false
      @packs_to_open.each do |set_code, count|
        next unless set_code and count and count > 0
        packs = $CardDatabase.boosters_for_descriptor(set_code)
        # Error handling ?
        next if packs.empty?
        count.times do
          # Checked per pack, so a slow pool stops partway instead of running
          # the process out of memory
          out_of_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
          break if out_of_time
          packs.sample.open.each{|card| @cards[card] += 1}
        end
        break if out_of_time
      end
      if out_of_time
        @warnings += ["Opening packs took too long, this pool is incomplete"]
      end
      # Still a multiset, now in the order the pool is shown and exported in
      @cards = @cards.sort_by{|card, _count|
        [
          -card.main_front.rarity_code,
          card.name,
          card.set_code,
          card.number_sort_index,
          # Premium finishes first, etched before foil, nonfoil last
          -PhysicalCard::FINISHES.index(card.finish),
        ]
      }.to_h
      # Our own decklist format, the one DeckExporter::Text writes and
      # DeckParser reads back, down to etched carrying the foil tag too
      @deck = @cards.map{|card, count|
        "#{count} #{card.name} [#{card.set_code.upcase}:#{card.number}]#{card.foil ? " [foil]" : ""}#{card.etched ? " [etched]" : ""}\n"
      }.join
    end

    @title = "Sealed"
  end

  # Options of the pack dropdowns. Every row offers the same packs, so this is
  # one list for all of them. Booster types have aliases, and the dropdown only
  # wants each pack once, under its own code.
  private def booster_options
    $CardDatabase.unique_supported_booster_types.map{|code, booster| [booster.name, code]} +
      random_booster_options
  end

  # There is no booster type for a pack picked at random out of a few, so a row
  # asking for one has nothing to select. Offer it as an extra option, named
  # after the packs it could be, at the end of every dropdown.
  private def random_booster_options
    @packs_to_open.map(&:first).uniq.filter_map do |set_code|
      next unless set_code&.include?("|")
      names = set_code.split("|").filter_map{|code| @booster_types[code]&.name}
      next if names.empty?
      ["Random: #{names.join(", ")}", set_code]
    end
  end
end

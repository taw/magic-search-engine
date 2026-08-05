class SealedController < ApplicationController
  # Controller supports >3 pack types
  def index
    counts = Array(params[:count]).map(&:to_i)
    set_codes = Array(params[:set])
    @fixed = params[:fixed]
    @warnings = []

    parse_fixed

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
      @cards = @fixed_cards.dup
      factory = PackFactory.new($CardDatabase)
      @packs_to_open.each do |set_code, count|
        next unless set_code and count and count > 0
        packs = packs_for(factory, set_code)
        # Error handling ?
        next if packs.empty?
        @cards.push *count.times.flat_map{ packs.sample.open }
      end
      @cards.sort_by!{|c|
        [
          -c.main_front.rarity_code,
          c.name,
          c.set_code,
          c.number_i,
          c.number,
          c.foil ? 0 : 1,
        ]
      }
      decklist_entries = @cards.map do |c|
        "#{c.name} [#{c.set_code.upcase}:#{c.number}]#{ c.foil ? ' [foil]' : ''}"
      end
      @deck = decklist_entries.group_by(&:itself).transform_values(&:size).map{|n,c| "#{c} #{n}\n"}.join
    end

    @title = "Sealed"
  end

  # Options of the pack dropdowns. Every row offers the same packs, so this is
  # one list for all of them. Booster types have aliases, and the dropdown only
  # wants each pack once, under its own code.
  private def booster_options
    @booster_types
      .select{|code, booster| code == booster.code}
      .map{|code, booster| [booster.name, code]} +
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

  # Packs one row of the form can open. Usually just one, but a pack the player
  # got at random out of a few - like the allied guild booster of the Dragon's
  # Maze prerelease - is passed as its alternatives joined by "|", and we roll
  # it separately for every pack of that row.
  private def packs_for(factory, set_code)
    set_code.split("|").filter_map{|code|
      code, variant = code.split("-", 2)
      factory.for(code, variant)
    }
  end

  # This is very hacky
  private def parse_fixed
    @fixed_cards = []
    (params[:fixed] || "").lines.grep(/\S/).map(&:strip).each do |line|
      case line
      when /\A(\d+)\s*x?\s*(.*[:\/].*)/i
        count = $1.to_i
        set_code, card_number, foil = $2.downcase.split(/\s*[:\/]\s*/, 3)
      when /\A(.*[:\/].*)/i
        count = 1
        set_code, card_number, foil = line.downcase.split(/\s*[:\/]\s*/, 3)
      else
        @warnings << "Invalid line: #{line}"
        next
      end
      set = $CardDatabase.sets[set_code]
      unless set
        @warnings << "Cannot find set with code: #{set_code} for line: #{line}"
        next
      end
      card = set.printings.find{|c| c.number.downcase == card_number }
      unless card
        @warnings << "Cannot find card set with number #{card_number} in set #{set_code} for line: #{line}"
        next
      end
      physical_card = PhysicalCard.for(card, foil == "foil")
      count.times do
        @fixed_cards.push(physical_card)
      end
    end
  end
end

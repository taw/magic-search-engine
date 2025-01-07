class SealedController < ApplicationController
  # Controller supports >3 pack types
  def index
    counts = params[:count].to_a.map(&:to_i)
    set_codes = params[:set].to_a
    @fixed = params[:fixed]
    @warnings = []

    parse_fixed

    @packs_to_open = set_codes.zip(counts)
    packs_requested = !@packs_to_open.empty?

    @booster_types = $CardDatabase.supported_booster_types

    if @packs_to_open.empty?
      most_recent_booster_type = $CardDatabase.most_recent_booster_type
      @packs_to_open << [most_recent_booster_type, 6]
    end
    @packs_to_open << [most_recent_booster_type, 0] while @packs_to_open.size < 3

    if packs_requested
      @cards = @fixed_cards.dup
      factory = PackFactory.new($CardDatabase)
      @packs_to_open.each do |set_code, count|
        next unless set_code and count and count > 0
        set_code, variant = set_code.split("-", 2)
        pack = factory.for(set_code, variant) or next
        # Error handling ?
        @cards.push *count.times.flat_map{ pack.open }
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

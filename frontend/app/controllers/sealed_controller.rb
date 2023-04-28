class SealedController < ApplicationController
  # Controller supports >3 pack types
  def index
    counts = params[:count].to_a.map(&:to_i)
    set_codes = params[:set].to_a

    @packs_to_open = set_codes.zip(counts)
    packs_requested = !@packs_to_open.empty?

    @booster_types = $CardDatabase.supported_booster_types

    if @packs_to_open.empty?
      most_recent_booster_type = $CardDatabase.most_recent_booster_type
      @packs_to_open << [most_recent_booster_type, 6]
    end
    @packs_to_open << [most_recent_booster_type, 0] while @packs_to_open.size < 3

    if packs_requested
      @cards = []
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
        "[#{c.set_code.upcase}:#{c.number}] #{c.name}#{ c.foil ? ' [foil]' : ''}"
      end
      @deck = decklist_entries.group_by(&:itself).transform_values(&:size).map{|n,c| "#{c} #{n}\n"}.join
    end

    @title = "Sealed"
  end
end

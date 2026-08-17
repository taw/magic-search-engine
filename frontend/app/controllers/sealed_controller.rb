class SealedController < ApplicationController
  # Controller supports >3 pack types
  def index
    counts = Array(params[:count]).map(&:to_i)
    set_codes = Array(params[:set])
    @fixed = params[:fixed]
    fixed_cards = FixedCardList.new($CardDatabase, params[:fixed])
    @warnings = fixed_cards.warnings

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
      @packs_to_open.each do |set_code, count|
        next unless set_code and count and count > 0
        packs = $CardDatabase.boosters_for_descriptor(set_code)
        # Error handling ?
        next if packs.empty?
        @cards.push *count.times.flat_map{ packs.sample.open }
      end
      @cards.sort_by!{|c|
        [
          -c.main_front.rarity_code,
          c.name,
          c.set_code,
          c.number_sort_index,
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

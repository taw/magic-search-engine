require_relative "card_database"

class CLIFrontend
  def initialize
    @db = CardDatabase.load
  end

  def call(verbose, query_string)
    query = Query.new(query_string)
    results = @db.search(query)

    # Should this be only reported in verbose mode?
    results.warnings.each do |w|
      warn w
    end

    if verbose
      print_results!(results)
    elsif query.view == "checklist"
      results.printings.each do |card|
        puts [card.set_code.upcase, card.number, card.name].join("\t")
      end
    else
      puts results.card_names
    end
  end

  def print_results!(results)
    cards = {}
    results.printings.each do |card_printing|
      (cards[card_printing.name] ||= []) << card_printing
    end
    cards.each_with_index do |(card_name, printings), i|
      card = printings[0].card
      if printings.size == card.printings.size
        codes = printings.sort_by(&:release_date).map(&:set_code)
      else
        codes = card.printings.sort_by(&:release_date).map do |cp|
          if printings.include?(cp)
            "+#{cp.set_code}"
          else
            "-#{cp.set_code}"
          end
        end
      end
      puts [card.name, card.display_mana_cost].compact.join(" ")
      puts "[#{codes.join(" ")}]"
      puts card.typeline
      puts "#{card.reminder_text}" if card.reminder_text
      puts "(Color indicator: #{card.name} is #{card.color_indicator})" if card.color_indicator
      puts "#{card.text}" if card.text != ""
      puts "#{card.display_power}/#{card.display_toughness}" if card.power
      puts "Loyalty: #{card.loyalty}" if card.loyalty
      puts "Stability: #{card.stability}" if card.stability
      puts "" unless i+1 == cards.size
    end
  end
end

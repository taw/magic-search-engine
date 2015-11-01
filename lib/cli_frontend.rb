require_relative "card_database"

class CLIFrontend
  def initialize
    json_path = Pathname(__dir__) + "../data/index.json"
    @db = CardDatabase.load(json_path)
  end

  def run!(verbose, query_string)
    query = Query.new(query_string)
    results = @db.search(query)
    if verbose
      print_results!(results)
    else
      puts results.map(&:name).uniq
    end
  end

  def print_results!(results)
    cards = {}
    results.each do |card_printing|
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
      puts "#{card.name} #{card.mana_cost}"
      puts "[#{codes.join(" ")}]"
      puts card.typeline
      puts "#{card.text}" if card.text != ""
      puts "#{card.power}/#{card.toughness}" if card.power
      puts "Loyalty: #{card.loyalty}" if card.loyalty
      puts "" unless i+1 == cards.size
    end
  end
end

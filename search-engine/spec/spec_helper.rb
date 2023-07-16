if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start
end

require_relative "../lib/card_database"
require_relative "../lib/cli_frontend"
require_relative "../lib/sealed"
require "pry"

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = :should
  end
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
end

RSpec::Matchers.define :include_cards do |*cards|
  match do |query_string|
    results = search_names(query_string)
    cards.all?{|card| results.include?(card)}
  end

  failure_message do |query_string|
    results = search_names(query_string)
    fails = cards.reject{|card| results.include?(card)}
    "Expected `#{query_string}' to include following cards:\n" +
      fails.map{|c| "* #{c}\n"}.join
  end
end

RSpec::Matchers.define :exclude_cards do |*cards|
  match do |query_string|
    results = search_names(query_string)
    results != [] and cards.none?{|card| results.include?(card)}
  end

  failure_message do |query_string|
    results = search_names(query_string)
    fails = cards.select{|card| results.include?(card)}
    if fails != []
      "Expected `#{query_string}' to exclude following cards:\n" +
        fails.map{|c| "* #{c}\n"}.join
    else
      "Test is unreliable because results are empty: #{query_string}"
    end
  end
end

RSpec::Matchers.define :return_no_cards do
  match do |query_string|
    search(query_string) == []
  end

  failure_message do |query_string|
    results = search(query_string)
    "Expected `#{query_string}' to have no results, but got following cards:\n" +
      results.map{|c| "* #{c}\n"}.join
  end
end

RSpec::Matchers.define :return_some_cards do
  match do |query_string|
    search(query_string) != []
  end

  failure_message do |query_string|
    "Expected `#{query_string}' to have some results, but got nothing"
  end
end

RSpec::Matchers.define :return_cards do |*cards|
  match do |query_string|
    search_names(query_string).sort == cards.sort
  end

  failure_message do |query_string|
    results = search(query_string)
    "Expected `#{query_string}' to return:\n" +
      (cards | results).sort.map{|c|
        (cards.include?(c) ? "[*]" : "[ ]") +
        (results.include?(c) ? "[*]" : "[ ]") +
        "#{c}\n"
      }.join
  end
end

RSpec::Matchers.define :return_printings do |*printings|
  match do |query_string|
    printings = printings.flatten
    search_printings(query_string).sort == printings.sort
  end

  failure_message do |query_string|
    "BAD for #{query_string}"
    # printings = printings.flatten
    # results = search_printings(query_string)
    # "Expected `#{query_string}' to return:\n" +
    #   (printings | results).sort.map{|c|
    #     (printings.include?(c) ? "[*]" : "[ ]") +
    #     (results.include?(c) ? "[*]" : "[ ]") +
    #     "#{c}\n"
    #   }.join
  end
end

RSpec::Matchers.define :equal_search do |query_string2|
  match do |query_string1|
    results1 = search(query_string1)
    results2 = search(query_string2)
    results1 == results2 and results1 != []
  end

  failure_message do |query_string1|
    results1 = search(query_string1)
    results2 = search(query_string2)
    if results1 != results2
      "Expected `#{query_string1}' and `#{query_string2}' to return same results, got:\n"+
        (results1 | results2).sort.map{|c|
        (results1.include?(c) ? "[*]" : "[ ]") +
        (results2.include?(c) ? "[*]" : "[ ]") +
        "#{c}\n"
      }.join
    else
      "Test is unreliable because results are empty: #{query_string1}"
    end
  end
end

RSpec::Matchers.define :include_search do |query_string2|
  match do |query_string1|
    results1 = search(query_string1)
    results2 = search(query_string2)
    results1 != [] and results2 != [] and results1.to_set >= results2.to_set
  end

  failure_message do |query_string1|
    results1 = search(query_string1)
    results2 = search(query_string2)
    if results1 != results2
      "Expected `#{query_string1}' to include all results from `#{query_string2}', got:\n"+
        (results1 | results2).sort.map{|c|
        (results1.include?(c) ? "[*]" : "[ ]") +
        (results2.include?(c) ? "[*]" : "[ ]") +
        "#{c}\n"
      }.join
    else
      "Test is unreliable because results are empty: #{query_string1}"
    end
  end
end

RSpec::Matchers.define :equal_search_cards do |query_string2|
  match do |query_string1|
    results1 = search_names(query_string1)
    results2 = search_names(query_string2)
    results1 == results2 and results1 != []
  end

  failure_message do |query_string1|
    results1 = search_names(query_string1)
    results2 = search_names(query_string2)
    if results1 != results2
      "Expected `#{query_string1}' and `#{query_string2}' to return same results, got:\n"+
        (results1 | results2).sort.map{|c|
        (results1.include?(c) ? "[*]" : "[ ]") +
        (results2.include?(c) ? "[*]" : "[ ]") +
        "#{c}\n"
      }.join
    else
      "Test is unreliable because results are empty: #{query_string1}"
    end
  end
end

RSpec::Matchers.define :have_count_cards do |count|
  match do |query_string|
    search_names(query_string).size == count
  end

  failure_message do |query_string|
    "Expected `#{query_string}' to return #{count} results, got #{search_names(query_string).size} instead."
  end
end

RSpec::Matchers.define :have_count_printings do |count|
  match do |query_string|
    search(query_string).size == count
  end

  failure_message do |query_string|
    "Expected `#{query_string}' to return #{count} results, got #{search(query_string).size} instead."
  end
end

shared_context "db" do |*sets|
  def load_database(*sets)
    $card_database ||= {}
    $card_database[[]]   ||= CardDatabase.load
    $card_database[[]].supported_booster_types # preload to avoid timeouts in specs
    $card_database[sets] ||= $card_database[[]].subset(sets)
  end

  def search(query_string)
    Query.new(query_string).search(db).card_ids
  end

  def search_names(query_string)
    Query.new(query_string).search(db).card_names
  end

  def search_printings(query_string)
    Query.new(query_string).search(db).printings
  end

  let!(:db) { load_database(*sets) }

  # FIXME: Temporary hacks to make migration to rspec easier, remove after migration complete
  def assert_search_results(query, *cards)
    query.should return_cards(*cards)
  end

  def assert_search_include(query, *cards)
    query.should include_cards(*cards)
  end

  def assert_include_search(query1, query2)
    query1.should include_search(query2)
  end

  def assert_search_exclude(query, *cards)
    query.should exclude_cards(*cards)
  end

  def assert_search_equal(query1, query2)
    query1.should equal_search(query2)
  end

  def assert_search_equal_cards(query1, query2)
    query1.should equal_search_cards(query2)
  end

  def assert_search_differ(query1, query2)
    query1.should_not equal_search(query2)
  end

  def assert_search_differ_cards(query1, query2)
    query1.should_not equal_search_cards(query2)
  end

  def assert_count_cards(query, count)
    query.should have_count_cards(count)
  end

  def assert_count_printings(query, count)
    query.should have_count_printings(count)
  end

  def assert_full_banlist(format, time, banned_cards, restricted_cards=[])
    time = Date.parse(time)
    expected_banlist = Hash[
      banned_cards.map{|c| [c, "banned"]} +
      restricted_cards.map{|c| [c, "restricted"]}
    ]
    actual_banlist = BanList[format].full_ban_list(time)
    expected_banlist.should eq(actual_banlist)
  end

  def assert_banlist_changes(date, *changes)
    prev_date = Date.parse(date)
    this_date = (prev_date >> 1) + 5
    changes.each_slice(2) do |change, card|
      raise unless change =~ /\A(.*) (\S+)\z/
      assert_banlist_change prev_date, this_date, $1, $2, card
    end
  end

  def assert_banlist_change(prev_date, this_date, format, change, card)
    if format == "vintage+"
      change_legacy = change
      case change
      when "banned", "restricted"
        change_legacy = "banned"
      when "unbanned", "unrestricted"
        change_legacy = "unbanned"
      when "banned-to-restricted", "restricted-to-banned"
        change_legacy = nil
      else
        raise
      end
      assert_banlist_change(prev_date, this_date, "vintage", change, card)
      assert_banlist_change(prev_date, this_date, "legacy", change_legacy, card) if change_legacy
      return
    end
    case change
    when "banned"
      assert_banlist_status(prev_date, format, "legal", card)
      assert_banlist_status(this_date, format, "banned", card)
    when "unbanned"
      assert_banlist_status(prev_date, format, "banned", card)
      assert_banlist_status(this_date, format, "legal", card)
    when "restricted"
      assert_banlist_status(prev_date, format, "legal", card)
      assert_banlist_status(this_date, format, "restricted", card)
    when "unrestricted"
      assert_banlist_status(prev_date, format, "restricted", card)
      assert_banlist_status(this_date, format, "legal", card)
    when "banned-to-restricted"
      assert_banlist_status(prev_date, format, "banned", card)
      assert_banlist_status(this_date, format, "restricted", card)
    when "restricted-to-banned"
      assert_banlist_status(prev_date, format, "restricted", card)
      assert_banlist_status(this_date, format, "banned", card)
    else
      raise "Unknown transition `#{change}'"
    end
  end

  def assert_banlist_status(date, format, expected_legality, card_name)
    if date.is_a?(Date)
      set_date = date
    else
      set_date = db.sets[set].release_date
    end
    actual_legality = BanList[format].legality(card_name, set_date) || "legal"
    [card_name, expected_legality].should eq([card_name, actual_legality])
  end

  # FIXME: All of this needs to be migrated to proper rspec
  def assert_block_composition(format_name, time, sets, exceptions={})
    time = db.sets[time].release_date if time.is_a?(String)
    format = Format[format_name].new(time)
    actual_legality = db.cards.values.map do |card|
      [card.name, format.legality(card)]
    end.select(&:last)
    expected_legality = compute_expected_legality(sets, exceptions)
    expected_legality.to_h.should eq(actual_legality.to_h) # "Legality of #{format_name} at #{time}"
  end

  def assert_legality(format_name, time, card_name, status)
    time = db.sets[time].release_date unless time.is_a?(Date)
    format = Format[format_name].new(time)
    card = db.cards[card_name.downcase] or raise "No such card: #{card_name}"
    format.legality(card).should == status # "Legality of #{card_name} in #{format_name} at #{time}"
  end

  def assert_block_composition_sequence(format_name, *sets)
    until sets.empty?
      assert_block_composition format_name, sets.last, sets
      sets.pop
    end
  end

  def compute_expected_legality(sets, exceptions)
    expected_legality = {}
    sets.each do |set_code|
      raise "Unknown set #{set_code}" unless db.sets[set_code]
      db.sets[set_code].printings.each do |card_printing|
        next if %W[vanguard planar scheme token].include?(card_printing.layout)
        next if card_printing.types == ["conspiracy"]
        next if card_printing.alchemy
        expected_legality[card_printing.name] = "legal"
      end
    end
    expected_legality.merge!(exceptions)
    expected_legality
  end

  def cards_matching(&block)
    db.cards.values.select(&block).map(&:name)
  end

  # If more than 1 returned, assuming it doesn't matter, and picking first by the usual order
  # (like with basic from same set)
  def physical_card(query, foil=false)
    card_printings = db.search(query).printings
    raise "No card matching #{query.inspect}" if card_printings.empty?
    PhysicalCard.for(card_printings[0], foil)
  end

  def physical_cards(query, foil=false)
    card_printings = db.search(query).printings
    raise "No card matching #{query.inspect}" if card_printings.empty?
    card_printings.map{|c| PhysicalCard.for(c, foil) }.uniq
  end
end

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 1_000_000

require 'minitest/autorun'
require_relative "../lib/card_database"
require_relative "../lib/cli_frontend"
require "pry"

class Minitest::Test
  # minitest is shitty and doesn't report test results in ordered way
  # because of some ridiculous fetishization of what was basically a workaround
  # for fucking mysql 3 in rails 1
  #
  # randomized *reporting* of results is just going full retard,
  # regardless of which order they're ran in - which should be predictable
  # unless you're still running mysql 3 or some other nontransactional nonsense
  def self.test_order
    :alpha
  end

  def assert_hash_equal(h1, h2, *msg)
    # Surely there oucht to be a plugin which fixes that, right?
    assert_equal(
      h1.sort.map{|k,v| "#{k} #{v}\n"}.join,
      h2.sort.map{|k,v| "#{k} #{v}\n"}.join,
      *msg
    )
  end

  def assert_search_results(query_string, *cards)
    query = Query.new(query_string)
    results = query.search(@db).card_names
    assert_equal cards.sort, results.sort, "Search for #{query_string} (#{query})"
  end

  def assert_search_results_ordered(query_string, *cards)
    query = Query.new(query_string)
    results = query.search(@db).card_names
    assert_equal cards, results, "Search for #{query_string} (#{query})"
  end

  def assert_search_results_printings(query_string, *card_printings)
    query = Query.new(query_string)
    expected = card_printings.map{|name, *sets| [name, *sets.sort]}
    actual   = query.search(@db).card_names_and_set_codes
    assert_equal expected, actual, "Search for #{query_string} (#{query})"
  end

  def assert_count_results(query_string, count)
    query = Query.new(query_string)
    results = query.search(@db).card_names
    assert_equal count, results.size, "Search for #{query_string} (#{query})"
  end

  def assert_search_include(query_string, *cards)
    query = Query.new(query_string)
    results = query.search(@db).card_names
    cards.each do |card|
      assert_includes results, card, "Search for #{query_string} (#{query})"
    end
  end

  def assert_search_exclude(query_string, *cards)
    query = Query.new(query_string)
    results = query.search(@db).card_names
    cards.each do |card|
      refute_includes results, card, "Search for #{query_string} (#{query})"
    end
  end

  def assert_search_equal(query_string1, query_string2)
    query1 = Query.new(query_string1)
    query2 = Query.new(query_string2)
    results1 = query1.search(@db).card_names
    results2 = query2.search(@db).card_names
    assert_equal results1, results2, "Queries `#{query1}' and `#{query2}' should return same results"
    assert results1.size > 0, "This test is unreliable if results are empty: #{query1}"
  end

  def assert_search_differ(query_string1, query_string2)
    query1 = Query.new(query_string1)
    query2 = Query.new(query_string2)
    results1 = query1.search(@db).card_names
    results2 = query2.search(@db).card_names
    refute_equal results1, results2, "Queries `#{query1}' and `#{query2}' should not return same results"
    assert results1.size > 0, "This test is unreliable if results are empty: #{query1}"
    assert results2.size > 0, "This test is unreliable if results are empty: #{query2}"
  end

  def load_database(*sets)
    # Cache for test performance
    $card_database ||= {}
    $card_database[[]]   ||= CardDatabase.load(Pathname(__dir__) + "../data/index.json")
    $card_database[sets] ||= $card_database[[]].subset(sets)
  end

  def load_cli
    # Don't load new database every time
    $cli_frontend ||= CLIFrontend.new
  end

  def find_set_change_at_date(date)
    date = Date.parse("#{date}")
    @regular_sets ||= @db.sets.values.select(&:regular?).sort_by(&:release_date)
    prev_set = @regular_sets.select{|set| set.release_date < date}.max_by(&:release_date).set_code
    this_set = @regular_sets.select{|set| set.release_date >= date}.min_by(&:release_date).set_code
    [prev_set, this_set]
  end

  def assert_banlist_status(date, format, expected_legality, card_name)
    if date.is_a?(Date)
      dsc = "#{date}"
      set_date = date
    else
      dsc = "#{set} (#{set_date})"
      set_date = @db.sets[set].release_date
    end
    actual_legality = @ban_list.legality(format, card_name, set_date) || "legal"
    assert_equal expected_legality, actual_legality, "Legality of #{card_name} in #{format} during #{dsc}"
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
      require 'pry'; binding.pry
    end
  end

  def assert_banlist_changes_by_set(date, *changes)
    prev_set, this_set = find_set_change_at_date(date)
    changes.each_slice(2) do |change, card|
      raise unless change =~ /\A(.*) (\S+)\z/
      assert_banlist_change prev_set, this_set, $1, $2, card
    end
  end

  def assert_banlist_changes(date, *changes)
    prev_date = Date.parse(date)
    this_date = (prev_date >> 1) + 5
    changes.each_slice(2) do |change, card|
      raise unless change =~ /\A(.*) (\S+)\z/
      assert_banlist_change prev_date, this_date, $1, $2, card
    end
  end

  def assert_full_banlist(format, time, banned_cards, restricted_cards=[])
    time = Date.parse(time)
    expected_banlist = Hash[
      banned_cards.map{|c| [c, "banned"]} +
      restricted_cards.map{|c| [c, "restricted"]}
    ]
    actual_banlist = @ban_list.full_ban_list(format, time)
    assert_hash_equal expected_banlist, actual_banlist, "Full banlist for #{format} at #{time}"
  end

  def assert_search_parse(query1, query2)
    assert_equal Query.new(query1), Query.new(query2), "`#{query1}' and `#{query2}' should be equivalent queries"
  end

  def refute_search_parse(query1, query2)
    refute_equal Query.new(query1), Query.new(query2), "`#{query1}' and `#{query2}' should not be equivalent queries"
  end

  def legality_information(name, date=nil)
    @db.cards[name].legality_information(date)
  end
end

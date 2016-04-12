Search engine for Magic: The Gathering cards.

== Ruby on Rails frontend ==

To run frontend like http://mtg.wtf/

    $ cd frontend
    $ bundle
    $ bundle exec rails s

== Command line ==

To search card names from command line:

    $ ./bin/find_cards "query"

To search card names and content from command line:

    $ ./bin/find_cards -v "query"

To explore card database from Ruby console:

    $ ./bin/pry_cards

== Testing ==

Tests for library and for Rails frontend are separate:

    $ rake test
    $ (cd frontend; rake test)

== How to update database ==

Whenever new set is released:

* Add new set code to legalities in Vintage
* Add new set code and date to legalities in Standard and Modern if applicable
* Create new block format if applicable and add it to indexer and Format class
* Update format tests

Then import cards:

* Run `rake mtgjson:update` to fetch mtgjson data and index it
* Run `rake test` and fix any tests failing due to data changes

Whenever banned and restricted list is announced:

* Update BanlistTest and/or BanlistCommanderTest
* Update Banlist data

If Comprehensive rules changed:

* Update `data/MagicCompRules.txt` with TXT format Comprehensive Rule
* Run `./bin/format_comp_rules`


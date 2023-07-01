Search engine for Magic: The Gathering cards.

### Ruby on Rails frontend

To run frontend like http://mtg.wtf/

    $ cd frontend
    $ bundle
    $ bundle exec rails s

### Command line

To search card names from command line:

    $ ./search-engine/bin/find_cards "query"

To search card names and content from command line:

    $ ./search-engine/bin/find_cards -v "query"

To explore card database from Ruby console:

    $ ./search-engine/bin/pry_cards

### Testing

Tests for library and for Rails frontend are separate:

    $ (cd search-engine; bundle install)
    $ (cd search-engine; bundle exec rspec)
    $ (cd frontend; bundle install)
    $ (cd frontend; bundle exec rake test)

### How to update database

Whenever new set is released:

* Run `rake rules:update` in case Comprehensive Rules changed
* If set is not Vintage-legal, add new set code to FormatVintage exclusions list
* Add new set code and date to legalities in Standard, Modern, Pioneer, and Frontier if applicable
* Update format tests
* `rake pennydreadful:update`

Then import cards:

* Run `rake mtgjson:update` to fetch mtgjson data and index it
  (this can fail if there are any mtgjson quality issues)
* Run `rake test` and fix any tests failing due to data changes

Whenever banned and restricted list is announced:

* Update `BanlistTest` and/or `BanlistCommanderTest`
* Update `Banlist` data

### Ban lists

* for official formats, wizards.com
* Commander: http://mtgcommander.net/index.php/rules
* MTGO Commander: https://magic.wizards.com/en/game-info/gameplay/rules-and-formats/banned-restricted/magic-online-commander
* Duel Commander: https://www.mtgdc.info/banned-restricted

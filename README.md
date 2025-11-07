Search engine for Magic: The Gathering cards.

### Ruby on Rails frontend

To run frontend like http://mtg.wtf/

    $ cd frontend
    $ bundle install
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

Make sure all relevant repositories are checked out, then run `rake update` to do the update process.

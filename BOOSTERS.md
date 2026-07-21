Here's how booster data goes into the system:

* card data is imported from mtgjson (`data/sets/*.json`), it contains a lot of metadata we'll use, like rarities, types, foiling status etc.
* every set has assigned base size (the second number in labels like "183/280") - it comes from mtgjson, but due to far too many errors there's override list for it in `indexer/lib/patches/patch_base_size.rb`. Normally cards with numbers up to base go into boosters, and those over it don't.
* for sets where it is necessary, print sheets data from `data/print_sheets` is added to the cards. There are multiple `indexer/lib/patches/patch*` handling it.
* yaml files describing each booster are in `data/boosters/*.yaml`, notably with common sheets extracted to `data/boosters/common.yaml`
* indexer marks sets which have their own booster yaml files with `st:booster`. It happens in `indexer/lib/patches/patch_set_types.rb`
* booster indexer `booster_indexer/bin/booster_indexer` preprocesses these yaml files into single file `index/booster_index.json`, doing a lot of preprocessing, and hopefully providing some error handling
* when the system starts, it uses `index/booster_index.json` for booster information, and resolves all the queries it contains

If you want to learn about yaml files describing each booster, check data/boosters/README.md

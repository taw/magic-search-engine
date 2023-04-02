Here's how booster data goes into the system:

* card data is imported from mtgjson (`data/sets/*.json`), it contains a lot of metadata we'll use, like rarities, types, foiling status etc.
* every set has assigned base size (the second number in labels like "183/280") - it comes from mtgjson, but due to far too many errors there's override list for it in `indexer/lib/patches/patch_base_size.rb`. Normally cards with numbers up to base go into boosters, and those over it don't.
* indexer decides which sets have boosters, and any nonstandard booster types like Arena. It happens in `indexer/lib/patches/patch_has_boosters.rb`. This step should eventually disappear, and metadata should be moved to booster yaml files.
* indexer decides which cards are `in:booster`, and which are not. No card that's not `in:booster` will ever be returned by any booster queries. Default logic is that `in:booster` is just `number<=set`, but there are many exceptions both ways. This happens in `indexer/lib/patches/patch_exclude_from_boosters.rb`.
* for sets where it is necessary, print sheets data from `data/print_sheets` is added to the cards. There are multiple `indexer/lib/patches/patch*` handling it.
* print sheet data is also calculated algorithmically by `indexer/lib/patches/patch_showcase.rb` for some sets
* yaml files describing each booster are in `data/boosters/*.yaml`, notably with common sheets extracted to `data/boosters/common.yaml`
* booster indexer `booster_indexer/bin/booster_indexer` preprocesses these yaml files into single file `index/booster_index.json`, doing a lot of preprocessing, and hopefully providing some error handling
* when the system starts, it uses `index/booster_index.json` for booster information, and resolves all the queries it contains

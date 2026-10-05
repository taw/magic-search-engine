# AGENTS.md

Search engine for Magic: The Gathering cards, running at https://mtg.wtf/.

## Layout

- `search-engine/` – the core Ruby library: `CardDatabase`, query tokenizer/parser, `lib/condition/` (one class per search condition), formats and banlists, decks, boosters/packs, deck exporters. CLI tools in `search-engine/bin` (`find_cards`, `pry_cards`, `open_packs`, profilers).
- `frontend/` – Rails app (views are `.haml`) on top of `search-engine/`.
- `indexer/` – turns mtgjson set files into `index/`. Data fixes live in `indexer/lib/patches/patch_*.rb`, one concern per patch.
- `booster_indexer/` – compiles `data/boosters/*.yaml` into `index/booster_index.json`. See `BOOSTERS.md` and `data/boosters/README.md`.
- `data/` – hand-maintained inputs: booster yaml, print sheets, limited formats, MTGO/Arena set codes and ids, comp rules.
- `index/` – generated, **committed** output the app loads at startup.
- `bin/` – maintenance and reporting scripts. They are extensionless, so never search with `--include=*.rb`.
- Sibling checkouts in `~/github` are part of the pipeline: `magic-search-engine-data` (mtgjson sets), `magic-preconstructed-decks`, `magic-sealed-data`, `magic-card-pics-*`.

## Commands

```sh
rake spec                                  # both suites (search-engine + frontend)
(cd search-engine; bundle exec rspec)      # library only
rake index                                 # rebuild index/ (indexer + booster indexer)
rake update                                # full data update
./search-engine/bin/find_cards -v "query"  # search from CLI
rake pry                                   # console with database loaded
rake rails:localhost                       # run the frontend
```

CI (`.semaphore/semaphore.yml`) runs both rspec suites and a production asset precompile.

## Working rules

- Never commit on `master`; leave changes in the working tree for review.
- Tests are integration tests against real card data. Coverage gaps mean reachable code; unreachable defensive branches are not worth testing.
- Verify indexer refactors by rebuilding `index/` and checking `git diff index/` is empty.
- Indexer/booster validation is report-only. Warnings are routine (spoiler season, mtgjson churn) and must not fail the build.
- mtgjson data is v5-only; don't add compatibility branches for older versions.
- Gitignored `_*.md` files in the repo root are local working notes. Never cite them from code comments; restate the fact instead.

## Memory and performance

The production server is memory constrained and about 4x slower than a local machine.

- Prefer precomputing in the indexer, or removing work, over adding caches.
- `CardPrinting` is at an object-size-pool edge: one extra instance variable costs tens of MB. Measure before adding fields.
- Don't make per-card display fields lazy (e.g. `name_slug`), because they run hundreds of times per page.
- No `# frozen_string_literal` pragmas. Fix the allocating method instead.
- When measuring memory, count live objects rather than RSS. Index JSON loading already interns strings.

## Data sources and pitfalls

- **Don't guess.** If booster contents, legality or dates are uncertain, record a known issue rather than a plausible-looking fix.
- mtgjson's booster and precon data comes from our own `magic-sealed-data`, so it can never confirm our files.
- Booster collation: lethe.xyz beats mtg.wiki and retailers. 17lands public draft dumps measure real Arena packs.
- mtgjson set language lists are inflated by promos, so treat them as an upper bound only. The printing language field is nil for both English and foreign promos.
- Scryfall `arena_code` is a copy of `mtgo_code`. Use 17lands `cards.csv` and mtg.wiki for Arena set codes.
- Scryfall marks unreleased sets as `not_legal`. Use WotC release notes for pre-release legality.
- Arena pre-bans appear only in Arena news, not on the official B&R page. Banlist dates within a couple of weeks are fine.
- Metagame data proves that a card sees play, never that it doesn't (MTGGoldfish caps at 50 rows).
- MTGO client card XML and the Arena card SQLite DB are both publicly downloadable over HTTP, and they are authoritative for those platforms.
- When diffing mtgjson sets, key cards by name+number+side, because both DFC faces share name and number.
- `foil: false, etched: true` is an illegal combination.
- Reversible cards are a modelling hack (faked as two cards) and are unrelated to DFCs.
- Errata sets are unused on mtg.wtf on purpose because forks with custom cards rely on them. Don't remove them.
- mtg.wiki returns 403 to plain fetchers, so use curl with a browser User-Agent.

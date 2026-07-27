# Other MTG Search Engines

Survey of the search engines/databases people actually use, and which of their features
mtg.wtf could plausibly pick up. Researched 2026-07.

## TL;DR

* **Scryfall syntax has won.** Moxfield, Archidekt, GrimDeck, Deckbox and most deckbuilders
  don't have their own query language — they embed Scryfall's, verbatim, and link to
  <https://scryfall.com/docs/syntax> as their documentation. Staying Scryfall-compatible is
  worth more than chasing anyone else.
* **Only a handful of engines have a genuinely independent query language worth mining:**
  Cube Cobra, MTGBAN, Commander Spellbook, and (loosely) the "similar card" finders.
* The biggest *actual* gaps vs. the field are **prices**, **Scryfall Tagger tags
  (`otag:`/`art:`)**, and **EDHREC rank/salt** — all three are things nearly every
  competitor exposes and we don't.

---

## The landscape

| Engine | Query language | Independent syntax? | Worth mining |
| --- | --- | --- | --- |
| [Scryfall](https://scryfall.com/docs/syntax) | own | yes — the de-facto standard | already our compatibility target |
| [Cube Cobra](https://cubecobra.com/wiki/reference/filter-syntax) | own (Scryfall-inspired) | **yes** | **yes** — several good ideas |
| [MTGBAN](https://mtgban.com/guide#basic-syntax) | own (Scryfall-inspired) | **yes** | **yes** — best *notation* ideas in the survey |
| [Commander Spellbook](https://commanderspellbook.com/syntax-guide/) | own (combo-oriented) | **yes** | partly — different problem domain |
| [Moxfield](https://moxfield.com) | Scryfall | no | no |
| [Archidekt](https://archidekt.com/faq) | Scryfall | no | no |
| [GrimDeck](https://grimdeck.com/search/syntax) | Scryfall-shaped | no | collection/wishlist filters only |
| [Deckbox](https://deckbox.org) | form-based | no | no |
| [Gatherer](https://gatherer.wizards.com/) | form-based | no | no (but it's the oracle/rulings source of truth) |
| [EDHREC](https://edhrec.com) | facets, not a query language | no | its *data* (rank, salt, synergy) |
| [MTGGoldfish](https://www.mtggoldfish.com) / [MTGStocks](https://www.mtgstocks.info) | form-based | no | price data only |
| [MTGTop8](https://mtgtop8.com/search) | form-based | no | tournament play-rate data |
| [17Lands](https://www.17lands.com/card_ratings) / [Lucky Paper](https://luckypaper.co/resources/) | none | no | limited-performance and cube-inclusion data |
| [ManaBox](https://www.manabox.app/guides/search/faq/) / [Delver Lens](https://www.delverlab.com/) | UI filters | no | no |
| [MTG Assist](https://mtgassist.com/), [MTG Replace](https://mtgreplace.com/), [Æther Search](https://mtgsimilarcards.com/) | none (single-card input) | no | **the "similar cards" idea itself** |
| MagicCards.info (MCI) | own | dead since ~2017 | already our other compat target |

---

## Cube Cobra

The only site besides Scryfall with a real, documented, independently-designed filter
language. Full reference: <https://cubecobra.com/wiki/reference/filter-syntax>.

Mostly it overlaps with what we already do (colors with `<`/`>`/`=` set comparisons,
`t:`, `o:`, `mv:`, `pow>toughness`, devotion, land-cycle `is:` nicknames — we have all of
these, often in more depth). What it has that we don't:

* **Numeric count comparisons on set-valued fields.** `keywords>3`, `keywords=0`,
  `oracletags>2`, `tags=0`. A card's keyword count is data we already have; `keyword>N`
  would be a small, self-contained addition. The general pattern — "same keyword, string
  operand matches a member, numeric operand compares the count" — is a nice bit of design.
* **Scryfall Tagger tags** (`otag:`/`oracletag:`, `atag:`/`arttag:`), imported from
  <https://tagger.scryfall.com/>, with hyphen-insensitive matching so `otag:boardwipe`,
  `otag:board-wipe` and `oracletag=boardwipe` all hit `board-wipe`. That hyphen-tolerance
  is a genuinely better UX than Scryfall's own.
* **EDHREC rank and salt** as first-class filters: `rank<=100` / `edhrec<=1000`,
  `salt>1.5`. Untracked cards sort as worst-rank / salt 0.
* **Prices**: `price:`, `priceNormal:`, `priceFoil:`, `priceEur:`, `priceTix:`.
* **`elo:`** — a per-card rating derived from Cube Cobra's own draft-bot pick data.
  Not reproducible without their data.
* **`year:`/`firstyear:`/`fy:`** — year of *first* printing, as its own scalar. We can
  express this with `firstprint`/`time`, but not as a plain numeric comparison.
* **`include:extras`** — tokens, emblems, art cards, planes, memorabilia and digital-only
  cards are hidden by default and opted into explicitly. We have `is:token`, `st:` etc.,
  but no single "show me the junk" switch.
* Cube-scoped only, not portable: `tag:`, `notes:`, `status:` (Owned/Proxied/Borrowed),
  `finish:`.

## MTGBAN

<https://mtgban.com/guide#basic-syntax> — a price/arbitrage aggregator (retail + buylist across
every tracked store) that happens to carry a full card-filter language on top. Open source, so
the authoritative list is [`searchfilter.go`](https://github.com/mtgban/mtgban-website/blob/main/searchfilter.go)
and [`js/guide-data.js`](https://github.com/mtgban/mtgban-website/blob/main/js/guide-data.js).

Half of it is a commerce layer we'd never implement (`price>`, `buy_price>`, `arb_price`,
`rev_price`, `ratio>`, `cond:`/`condr:`/`condb:`, `store:`/`seller:`/`vendor:`/`store:only:`,
`region:us|eu|jp`, `skip:retail|buylist|index|empty`, `qty>`, `sort:retail|buylist`,
`on:hotlist|ckp90|tcgsyp|newspaper|mtgstocks`). The other half is a card filter that's a partial
Scryfall clone — and it has **the most interesting notation ideas in this whole survey**, because
it's optimised for people pasting card identifiers around rather than for composing predicates.

Portable ideas, roughly in order of how much I'd want them:

* **Finish suffixes appended to any search term** — `Sol Ring*` (foil), `Sol Ring&` (nonfoil),
  `Sol Ring~` (etched), ``Sol Ring` `` (alt-foil: surge/ripple/galaxy/…). One character instead of
  a whole `is:foil` clause, and it attaches per-term rather than to the whole query.
* **Comma as OR within a single filter** — `r:rare,mythic`, `format:legacy,vintage`,
  `is:showcase,borderless`. We currently need `(r:rare or r:mythic)`. Neither Scryfall nor Cube
  Cobra has this; it's a real terseness win and it composes with negation (`-format:x,y`).
* **Pipe notation for a card identifier** — `name|SET|number|finish`, e.g. `Lightning Bolt|LEA`.
  Compact single-token locator, and it's what price bots and several deck exporters already emit,
  so users arrive with strings in this shape. Cheap to parse into our existing `e:`/`number:`/foil
  conditions.
* **Human-readable variant tags inside the name** — `Sheoldred (Showcase)`, `Sol Ring
  (Extended Art)`. This is exactly how TCGplayer, Moxfield and most collection CSVs render a
  printing, so accepting it means pasted names Just Work. Maps onto our existing `is:showcase`,
  `frame:extendedart`, etc.
* **Set-scoped collector number** — `cn:MKM:42` constrains the number filter *only* for that set
  and leaves other sets' results untouched. Also plain `cn:1-50` ranges (we have ranges via
  `number:`, but not the scoping form).
* **`is:altfoil` as a data-driven union** — one keyword matching any special foil treatment
  (surge, galaxy, ripple, rainbow, halo, mana, silver, fracture, confetti, neon ink, gilded,
  textured, oil slick, invisible ink, double exposure, double rainbow, step-and-compleat, raised,
  embossed). Their guide explicitly notes the list "tracks the live card data, so newer treatments
  work as soon as the data includes them even if not listed here" — worth contrasting with our
  hardcoded `PROMO_TYPE` regexp in `search-engine/lib/query_tokenizer.rb`, which has to be edited
  by hand every set.
* **`sm:` search modes** — `exact` (their default!), `prefix`, `any`, `regexp`, `scryfall`.
  Two things stand out: they default to *exact* name matching where everyone else defaults to
  substring, and `sm:scryfall` proxies the entire query to Scryfall when their own filters can't
  express it. An explicit mode switch is a cleaner answer than our current mix of `name:`,
  `!exact`, and regexp forms.
* **`id:` that sniffs the ID format** — one keyword accepting MTGBAN, MTGJSON, Scryfall and
  TCGplayer product IDs interchangeably. Useful for round-tripping from any external tool.
* **`is:power9`/`is:p9`, `is:abu4h`** (Alpha/Beta/Unlimited + first four expansions) — trivial
  named card/set groups we don't have. Also `is:vergeland`, which we lack among our land cycles.
* **`is:productless`** — cards not present in any tracked sealed product. The inverse of what our
  `booster:`/`sheet:` conditions do, and a decent "why can't I open this" query.
* **`contents:` / `container:` / `unpack:` / `decklist:`** — bidirectional sealed-product search:
  find the products containing a card, or the cards inside a product, including precon decklists.
  Our `booster:` and `sheet:` cover randomized boosters well (arguably better), but not
  boxes/bundles/precons, which is where MTGJSON's sealed data has grown.

Things they have that we already do as well or better: colors with guild/shard/college names,
`t:` over the full type line (theirs also matches sealed product categories), `r:` with
comparisons, `format:`/`legal:` across ~22 formats, `date:`/`year:` including `date:SETCODE` and
`now`/`today` (our `time:` already accepts set codes and dates), `se:`/`ee:`/`cne:`/`namee:`
regexp variants, land cycles, and a promo-type catalog that's a subset of ours.

Note `e:CODE` is accepted "for compatibility" alongside `s:CODE` — MTGBAN is inheriting the same
MCI/Scryfall vocabulary we are.

## Commander Spellbook

Searches *combos*, not cards, so most of it doesn't transfer — but the vocabulary is
instructive. Reference: <https://commanderspellbook.com/syntax-guide/>.

* Structural filters over a combo: `prerequisites:`/`pre:`, `steps:`, `results:`,
  `card<=3` (number of cards in the combo), `@card`/`all-cards` (every card must match).
* `is:` tags on combos: `commander`, `featured`, `reserved`, `hulkline`/`meatandeggs`,
  `winning`/`win`, `lock`, `mld`.
* `popularity:`/`pop:`/`deck:` — EDHREC deck count.
* `price:`/`usd:`/`tcgplayer:`/`cardmarket:` — total cost of the whole combo.
* `bracket:` — the Commander bracket system.
* `spellbookid:` — stable combo IDs.

Nothing here is a quick win for us; the useful takeaway is that `popularity:` and
`bracket:` are becoming expected vocabulary in the Commander-facing corner of the hobby.

## The Scryfall-syntax clients (Moxfield, Archidekt, GrimDeck, Deckbox)

Worth stating plainly because it changes priorities: these sites, which collectively have
far more traffic than Scryfall's own search, are **just Scryfall's parser**. Users arrive
at them already fluent in `o:`, `t:`, `id:`, `order:`. Any Scryfall keyword we don't
support is a keyword four other popular sites also appear to support.

Their only original additions are account-scoped and inherently unportable:

* GrimDeck: collection / wishlist / "in my binder" filters, precon browsing, Secret Lair
  tracking, USD+EUR price ranges.
* Moxfield/Archidekt: filter-within-deck using the same syntax (their killer feature is
  applying a card query to a decklist rather than the whole corpus).

The "apply a query to a list of cards you paste in" idea is the one portable piece — we
have `deck:` and `decklimit:` already, so we're arguably ahead here.

## Gatherer

Rebuilt visually in June 2025; still a form-based search with no query language. Its value
is being the authoritative source for Oracle text and rulings, both of which we already
index (`o:`, `rulings:`). No features to copy.

## Data-only sites (EDHREC, MTGGoldfish, MTGStocks, MTGTop8, 17Lands, Lucky Paper)

None of these have a query language, but each publishes a *scalar per card* that other
search engines then expose as a filter. This is where the field has moved past us:

| Source | Scalar | Who already exposes it as a search keyword |
| --- | --- | --- |
| EDHREC | popularity rank | Scryfall (`edhrecrank:`), Cube Cobra (`rank:`) |
| EDHREC | salt score | Cube Cobra (`salt:`) |
| TCGplayer / Cardmarket / MTGO | usd / eur / tix price | Scryfall, Cube Cobra, GrimDeck |
| Cube Cobra draft bots | elo | Cube Cobra (`elo:`) |
| Cube Cobra corpus | # of cubes containing the card | Cube Cobra (sortable column) |
| MTGTop8 | tournament play count per format | nobody, as a query keyword |
| 17Lands | GIH win rate, ALSA | nobody, as a query keyword |

MTGTop8 play-rate and 17Lands win-rate are unclaimed territory — no search engine exposes
them as query keywords today.

## "Similar card" finders (MTG Assist, MTG Replace, Æther Search)

A small cluster of sites whose entire product is one operation: *give me a card, get
functionally similar / cheaper alternatives.* They have no query syntax at all — the whole
UI is one card-name box.

This is the one feature in the whole survey that nobody has expressed as a search operator.
A `similar:"Lightning Bolt"` / `like:` condition over oracle text + type + mana value would
be novel, would compose with everything else we have (`similar:"Wrath of God" f:pauper`),
and needs no external data.

---

## Candidate features, ranked by (value / effort)

**Quick, no new data source:**

1. `keyword>N` / `keyword=0` — numeric count comparison on keywords. Extends
   `condition_keyword.rb`; data already indexed.
2. `year:` as a plain numeric on first-print year, alias over what `firstprint`/`time`
   already computes.
3. `include:extras`-style single switch for tokens/emblems/art-series/memorabilia.
4. Hyphen-insensitive matching for any slug-shaped operand (Cube Cobra's trick) — cheap
   politeness, applies to watermarks, promo types, frame effects, set types.
5. **Comma as OR inside one filter** (MTGBAN) — `r:rare,mythic`, `f:legacy,vintage`. Purely a
   tokenizer/parser change, no new data, and nobody else offers it.
6. **Finish suffixes** (MTGBAN) — `Sol Ring*` / `&` / `~`. Same, and very cheap.
7. **`is:altfoil`-style union keyword** over special foil treatments, ideally generated from the
   data rather than hand-listed — directly relevant to the hardcoded `PROMO_TYPE` regexp we keep
   having to edit.
8. **Pasted-identifier tolerance** (MTGBAN) — `Name|SET|number|finish` pipe notation and
   `Name (Showcase)` parentheticals. Makes strings pasted from TCGplayer, price bots and
   collection CSVs work without editing.
9. `is:power9`, `is:abu4h`, `is:vergeland` — trivial named groups we're missing.

**Needs a new data feed, but a well-defined one:**

10. **EDHREC rank** (`edhrecrank:`) — in Scryfall bulk data as `edhrec_rank`; Scryfall
    already has this keyword, so it's a compatibility gap, not just a feature gap.
    Also `penny_rank` for `pennyrank:`.
11. **Prices** (`usd:`, `eur:`, `tix:`, plus `cheapest:`) — Scryfall bulk carries
    `prices.{usd,usd_foil,usd_etched,eur,eur_foil,tix}` per printing; MTGJSON has
    `AllPrices.json`. Caveat: these change daily, so it means either a churning index or
    a separate price file loaded at query time. Probably the single most-requested thing
    we don't have. MTGBAN shows the ceiling here (per-store, per-condition, buylist vs
    retail) — the sane subset for us is a single reference price per printing.
12. **Scryfall Tagger tags** (`otag:`/`function:`, `atag:`/`art:`) — community-curated
    functional and art tags. Not in the standard bulk downloads; Cube Cobra manages to
    import them, so it's feasible, but it's the highest-effort item here and the data is
    third-party and incomplete. High user value: `function:removal`, `art:squirrel`.
13. **Sealed product contents** (`container:`/`contents:`, MTGBAN) — boxes, bundles and precon
    decklists from MTGJSON sealed data, extending what `booster:`/`sheet:` already do for
    randomized boosters.
14. EDHREC salt score — small file, easy, but niche and only meaningful for Commander.

**Novel / differentiating rather than compatibility:**

15. `similar:`/`like:` — a "find cards like this one" operator, claiming the one job the
    MTG Assist / MTG Replace / Æther Search cluster does with no syntax at all.
16. MTGTop8 or 17Lands scalars as keywords (`played:`, `gihwr:`). Nobody has done it.
    Data licensing/scraping is the obstacle, not the search engine.

**Deliberately out of scope:**

* Combo search (Commander Spellbook) — different data model entirely.
* Cube-scoped filters (`tag:`, `notes:`, `status:`, `elo:`) — require per-user cube state.
* Collection/wishlist filters (GrimDeck, Deckbox, ManaBox) — require user accounts.
* The entire MTGBAN commerce layer — per-store, per-condition, retail-vs-buylist pricing,
  arbitrage ratios, regions. That's a different product, not a search feature.

---

## Sources

* [Scryfall Search Reference](https://scryfall.com/docs/syntax) · [Tagger Tags](https://scryfall.com/docs/tagger-tags) · [Tagger](https://tagger.scryfall.com/)
* [Cube Cobra Filter Syntax](https://cubecobra.com/wiki/reference/filter-syntax)
* [MTGBAN guide](https://mtgban.com/guide#basic-syntax) · source: [`searchfilter.go`](https://github.com/mtgban/mtgban-website/blob/main/searchfilter.go), [`js/guide-data.js`](https://github.com/mtgban/mtgban-website/blob/main/js/guide-data.js)
* [Commander Spellbook Syntax Guide](https://commanderspellbook.com/syntax-guide/)
* [Moxfield primer](https://gist.github.com/Jerakin/24be913c6106546136c45d1d028f9af9) · [Archidekt FAQ](https://archidekt.com/faq) · [GrimDeck syntax](https://grimdeck.com/search/syntax)
* [Gatherer](https://gatherer.wizards.com/) · [A Fresh Look for Gatherer](https://magic.wizards.com/en/news/announcements/a-fresh-look-for-gatherer)
* [EDHREC](https://edhrec.com/) · [MTGTop8 most played cards](https://mtgtop8.com/topcards) · [17Lands card ratings](https://www.17lands.com/card_ratings) · [Lucky Paper resources](https://luckypaper.co/resources/)
* [MTG Assist](https://mtgassist.com/) · [MTG Replace](https://mtgreplace.com/) · [Æther Search](https://mtgsimilarcards.com/)
* [ManaBox search FAQ](https://www.manabox.app/guides/search/faq/) · [Delver Lens](https://www.delverlab.com/)
* [Best MTG deck builder sites 2026 comparison](https://grimdeck.com/blog/best-mtg-deck-builder-sites) · [Scryfall competitors (Similarweb)](https://www.similarweb.com/website/scryfall.com/competitors/)

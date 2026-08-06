# Deck list formats

Research notes for [issue #348](https://github.com/taw/magic-search-engine/issues/348)
("'Preview deck' list not importable elsewhere"). The ask is: what should mtg.wtf be
able to *export* so that sealed pools / precon decks land in other tools, and what should
it be able to *import*?

This document is a survey, not a plan. It records what each format actually looks like,
how confident I am about it, and which of them are worth supporting. Nothing here has
been implemented.

Verification markers used throughout:

* ✅ — verified against source code of the reading/writing program, or a live file/API
* ⚠️ — secondhand (docs, third-party parsers, forum posts); shape is probably right, details may drift
* ❓ — plausible but unconfirmed; do not build on it without checking

---

## 1. What mtg.wtf does today

### Export

`PreconDeck#to_text` and `#to_text_with_printings` (`search-engine/lib/precon_deck.rb:38,80`),
used by `/deck/:set/:id/download` and `/download_with_printings`
(`frontend/app/controllers/deck_controller.rb:10,18`):

```
// NAME: Blood Rush - Dragon's Maze Event Deck
// URL: http://mtg.wtf/deck/dgm/blood-rush
// DATE: 2013-05-03
COMMANDER: 1 Some Commander [DGM:1]
4 Lightning Bolt [M10:146] [foil]

Sideboard
2 Naturalize [M10:180]
```

The sealed generator (`frontend/app/controllers/sealed_controller.rb:44`) emits the same
card syntax, one line per distinct printing:

```
1 Sire of Seven Deaths [FDN:292]
1 Day of Judgment [FDN:140] [foil]
```

Properties of this format:

* set code and collector number in one `[SET:NUM]` bracket, **after** the card name
  (moved there in response to this issue)
* foil and etched as separate `[foil]` / `[etched]` tags
* section headers as bare words (`Sideboard`, `Planar Deck`, `Scheme Deck`,
  `Display Commander`), commander as a `COMMANDER:` line prefix
* metadata as `//` comments, including every line of a multiline `DISPLAY:`
* collector numbers are **Gatherer-style, one per face** (`4a` / `4b`), not Scryfall-style
  one-per-physical-card — this is the single biggest interop problem (see §5.1)

Who can read it: mtg.wtf itself, XMage (its `.dck` importer uses the same
`[SET:NUM]` bracket, though it puts the bracket *before* the name), MythicHub
(confirmed by its author in the issue thread). Essentially nobody else.

### Import

Two layers:

* `UserDeckPreprocessor` (`search-engine/lib/user_deck_preprocessor.rb`) — sniffs XML first:
  Cockatrice `.cod` (`<cockatrice_deck>`) and MTGO `.dek` (`<Deck><Cards …>`); strips
  XMage's `NAME:` / `LAYOUT MAIN:` / `LAYOUT SIDEBOARD:` metadata lines; handles
  UTF-8/CP1252/BOM/CRLF; converts an MTGO-style blank-line split into `SB:` lines, but
  only for a list that names no sections of its own — an Arena list's blank lines
  separate sections it already labelled.
* `DeckParser` (`search-engine/lib/deck_parser.rb`) — the line parser:
  `N` or `Nx` quantity, `#` and `//` comment lines, printing either as our own
  `[SET]` / `[SET:NUM]` / `[SET/NUM]` bracket or as an Arena-style `(SET) NUM` /
  `(PLST) MH2-123` suffix, `[foil]` / `[etched]` tags or `*F*` / `*E*` markers (any other
  `*MARKER*` and any trailing `#tag` are dropped). Every section we export has a header,
  either on a line of its own (`Sideboard`, `sideboard:`, `Sideboard (15)`, `Planar Deck`,
  `Scheme Deck`, `Display Commander`, `Deck`, `Mainboard`) or as a per-card prefix
  (`SB:`, `COMMANDER:`); Arena's `Companion` folds into the sideboard and its `About`
  block is dropped. Then a commander heuristic for 60/100-card lists whose sideboard is
  1–2 cards. Every deck on the site round trips through both exports, which
  `deck_parser_spec.rb` checks.

The collector number is optional, so Cockatrice's and TappedOut's `(set)`-only lines work
too — but a parenthetical is only read as a printing when the full name isn't a card we
know. 15 real card names end in something set-code-shaped, and 14 of them resolve to a
*different real card* once the parens come off (`Bind (CMB1)` → Invasion's Bind,
`Fire (CMB1)` → Apocalypse's Fire). One of them, `Unquenchable Fury (TBTH)`, is in a deck
we ship, so without the check our own `to_text` export no longer reads back.

That asymmetry is worth remembering when weighing any other parser guess: a wrong set code
or collector number costs a printing, because `DeckParser#select_best_printing` keeps the
unfiltered list when a filter empties it. A wrong *name* has no fallback at all.

Gaps that remain:

| Gap | Effect |
| --- | --- |
| `//Sideboard`, `//Maybeboard` treated as comments | Deckstats lists import as 100% mainboard |
| Deckstats `[SET#NUM]` | The bracket parser only splits on `:` or `/`, so `[2XM#310]` resolves as a set code of `2XM#310` |
| Bare `[Category]` still read as a set code | `1x Sol Ring [Ramp]` sets `set_code = "Ramp"`. Archidekt lines that also carry `(c21) 263` are fine — the parens win — but a category on its own is still mistaken for a set |
| Quantity only as `N` / `Nx` | Cockatrice also writes `x4`, `[4]`, `(4)` |
| `1 Bind (CMB1) 88` | A *numbered* line for one of the 15 cards whose name ends in a set code is genuinely ambiguous, and we read it as a printing. Only the unnumbered form is protected |
| Arena's Alchemy set codes and `A-` names | `(Y22)`/`(Y23)` are not in `data/arena_set_codes.txt`, and a rebalanced `A-Yorion, Sky Nomad` is not a paper card, so both fall back to name lookup |

The bracket syntax mtg.wtf chose for printings is the same syntax Archidekt uses for
user-defined categories, which is exactly what the second reporter in the issue ran into
from the other direction.

---

## 2. The de facto standard

There is no committee-blessed decklist format, but there *is* a clear winner by adoption:
the line shape MTG Arena introduced.

```
<count> <name> (<SET>) <collector number>
```

with optional `x` after the count, optional `*F*` foil marker, and section headers on
their own lines. Programs verified to read some form of it: MTG Arena, Moxfield,
Archidekt, Deckstats, ManaBox, TappedOut, MTGGoldfish, Cockatrice ✅, XMage ✅,
Draftmancer ✅, Scryfall, TopDecked, MythicHub, and every "paste a decklist" proxy site.

Cockatrice's parser (`libcockatrice/deck_list/deck_list.cpp`, ✅ read from source) is a
good model of what a tolerant reader accepts today:

* quantity as `4`, `4x`, `x4`, `[4]`, `(4)`
* `(SET) 123` **and** the hyphenated The-List form `(PLST) MH2-123`
* `*F*` suffix (parsed, then discarded)
* sideboard by `SB:` prefix, a `Sideboard…` header line, or a blank line
* `deck` / `mainboard` / `decklist` header lines skipped
* leading lines before the first card become deck name + comments

If mtg.wtf only ever adds one new export, this is the one. It covers essentially every
destination named in the issue thread.

---

## 3. Text decklist formats

### 3.1 Arena (`.txt`) ⚠️ (shape confirmed by three independent parsers)

```
About
Name Death & Taxes

Companion
1 Yorion, Sky Nomad

Deck
2 Arid Mesa (MH2) 244
1 Lion Sash (NEO) 232

Sideboard
2 Containment Priest (M21) 13
```

* Sections: `About` (with `Name <deck name>`), `Deck`, `Sideboard`, `Commander`,
  `Companion`. Unlabelled variant: first block is main, second is sideboard.
* Blank line between sections is required.
* Arena's set codes and numbers are Arena's own: `DAR` instead of `DOM` for Dominaria
  (XMage hardcodes that remap ✅), `Y22`/`Y23`-prefixed Alchemy sets, `A-` prefixed
  rebalanced cards ❓, and Arena-only sets (`ANA`, `HA1`…). Paper-only cards simply
  cannot be expressed. An mtg.wtf sealed pool from a paper set will not import into Arena
  no matter how it's formatted — the value of this format is that *everything else* reads it.

### 3.2 Moxfield ⚠️

```
1 Ainok Bond-Kin (2X2) 5
4 Counterspell (CMR) 632 *F* #TargetedDisruption
1 Pegasus Guardian // Rescue the Foal (CLB) 36

SIDEBOARD:
1 Containment Priest (M21) 13
```

* `<count> <name> (<SET>) <number> [*F*] [#tag …]`; `#!tag` is a collection-wide tag.
* `SIDEBOARD:` header; commanders live in their own section in the UI and export.
* Etched printings: Moxfield's CSV foil column carries a literal `etched` value ✅
  (verified in MtgCsvHelper's round-trip notes); whether the text export uses `*E*` is ❓.
* Import is name-anchored: (set + number) with a blank name is rejected ✅, and a *wrong*
  collector number is silently fuzzy-matched to some other printing ✅ — so a bad number
  fails quietly rather than loudly.

### 3.3 Archidekt ⚠️

```
1x Agadeem's Awakening // Agadeem, the Undercrypt (znr) 90 [Resilience,Land]
1x Ancient Cornucopia (big) 16 [Maybeboard{noDeck}{noPrice},Mana Advantage]
1x Ashnod's Altar (ema) 218 *F* [Mana Advantage]
1x Amulet of Vigor (plst) WWK-121 *F* [Ramp] ^Label,#000000^
```

* `<count>x <name> (<set>) <number> [*F*] [<categories>] [^label,#colour^]`
* Categories in `[…]`, comma-separated, with `{flags}`; `Maybeboard`/`Sideboard`/
  `Commander` are expressed as categories.
* Its *text* import reportedly ignores collector numbers (only `(set)` is honoured);
  full number support is via CSV upload ⚠️. Categories are subjective and mtg.wtf has
  nothing to put there — omitting the `[…]` block entirely is fine and imports cleanly.

### 3.4 Deckstats ✅ (shape cross-checked in XMage + silhouette-card-maker)

```
//Main
1 [2XM#310] Ash Barrens
1 Blinkmoth Nexus

//Sideboard
1 [2XM#315] Darksteel Citadel

//Maybeboard
1 [MID#159] Smoldering Egg // Ashmouth Dragon
```

* Printing as `[SET#NUM]` **before** the name; sections as `//`-comments; also accepts
  `SB:` per-line prefixes; trailing `#…` on a card line is a per-card comment ✅.

### 3.5 MTGO ✅

Plain text, no printings at all:

```
1 Ainok Bond-Kin
2 Witch Enchanter

SIDEBOARD:
1 Containment Priest
```

Blank line or `SIDEBOARD:` splits the boards. Older exports are tab-separated
(XMage's importer converts tabs to spaces ✅). MTGO also exports the XML `.dek` (§4.2).

### 3.6 Magic Workstation `.mwDeck` ✅ (XMage source)

```
// Deck comment
4 [10E] Lightning Bolt
SB: 2 [10E] Naturalize
```

Count, `[SET]`, name. Legacy, but still an export option on MTGTop8 and similar sites.

### 3.7 Apprentice / Decked Builder `.dec` ✅ (XMage source)

```
// comment
4 Lightning Bolt
SB: 2 Naturalize
```

Names only. This is the lowest common denominator that everything reads.

### 3.8 XMage `.dck` ✅ (XMage source)

```
NAME: My Deck
1 [ISD:144] Delver of Secrets
SB: 2 [ISD:60] Lost in the Mist
LAYOUT MAIN:(3,5)([ISD:144],[ISD:60])|…
```

Bracket **before** the name, `SB:` prefix, optional `NAME:` and `LAYOUT` lines. Note
mtg.wtf's `UserDeckPreprocessor` already strips the `NAME:`/`LAYOUT` lines, and mtg.wtf's own
export is this format with the bracket moved after the name.

### 3.9 TappedOut ⚠️

`1x Card Name (set) *F* *CMDR*` with a `Sideboard:` header; `*CMDR*` marks the commander.
TappedOut also offers MTGO / Arena / `.dek` / `.cod` / `.mwDeck` export modes.

### 3.10 Draftmancer custom card list ✅ (official docs)

Arena-derived card lines plus cube structure:

```
[Settings]
{"name": "My Cube", "boostersPerPlayer": 3}
[Common(10)]
1 Incubation Druid (RNA) 131
[Rare(1)]
…
```

`[Count] CardName [(Set) [CollectorNumber]]`; a collector number without a set is
invalid. Directly relevant if mtg.wtf ever wants "draft this sealed pool" output.

### 3.11 Vendor mass-entry ⚠️

TCGplayer Mass Entry: `1 Lightning Bolt [SLD] 84` — quantity, name, `[set]`, number.
Card Kingdom / CoolStuffInc / Star City deck builders accept quantity + name, and mostly
ignore anything after it ❓. A "buy this pool" export is a real use case for sealed but
the syntaxes are vendor-specific and poorly documented.

---

## 4. Structured (XML/JSON) deck files

### 4.1 Cockatrice `.cod` ✅ (live file + source)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<cockatrice_deck version="1">
    <deckname>My Deck</deckname>
    <comments></comments>
    <zone name="main">
        <card number="4" price="0" name="Lightning Bolt"/>
    </zone>
    <zone name="side">
        <card number="2" price="0" name="Naturalize"/>
    </zone>
</cockatrice_deck>
```

Already supported on import (`user_deck_preprocessor.rb:26`). Cockatrice accepts
`*.cod *.dec *.dek *.txt *.mwDeck` on open ✅ but only writes `.cod` and plain text ✅ —
its plain-text writer emits `<count> <name>` with no printings, so round-tripping through
Cockatrice loses set info.

### 4.2 MTGO `.dek` ✅ (XMage source, matches mtg.wtf's own parser)

```xml
<Deck xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <NetDeckID>0</NetDeckID>
  <PreconstructedDeckID>0</PreconstructedDeckID>
  <Cards CatID="61202" Quantity="1" Sideboard="false" Name="Vildin-Pack Outcast" />
</Deck>
```

`CatID` is an MTGO catalog id, which mtg.wtf does have via mtgjson (`mtgoId`) but does not
currently load. Importing by `Name` (what mtg.wtf does today) is the pragmatic choice;
exporting a *valid* `.dek` would need real CatIDs, since MTGO matches on them.

### 4.3 OCTGN `.o8d` ✅ (XMage source + a third-party exporter)

```xml
<deck game="a6c8d2e8-7cd8-11dd-8f94-e62b56d89593">
  <section name="Main">
    <card qty="4" id="…guid…">Lightning Bolt</card>
  </section>
  <section name="Sideboard">…</section>
</deck>
```

Card ids are OCTGN's own GUIDs; niche today.

### 4.4 LackeyCCG `.dek` ✅ (live file)

```xml
<deck version="0.8">
  <meta><title/><author/><game/><format/></meta>
  <superzone name="Deck"><card><name id="…">Card Name</name></card></superzone>
  <superzone name="Sideboard">…</superzone>
</deck>
```

One `<card>` element per physical copy (no quantity attribute). Very niche.

### 4.5 Forge `.dck` ✅ (live file from the Forge repo)

INI-style, *not* XML:

```
[metadata]
Name=Adventure - King Giott
[Avatar]

[Main]
2 Cloudbound Moogle
7 Mountain|FIN|2
7 Plains|FIN|1
[Sideboard]

[Planes]

[Schemes]

[Conspiracy]
```

Card line is `<count> <name>[|<SET>[|<art index>]]`. Sections cover
`Main`/`Sideboard`/`Avatar`/`Planes`/`Schemes`/`Conspiracy` (and `Commander`/`Dungeon`
in newer builds ❓) — a closer match to mtg.wtf's own section model (planar decks, scheme
decks) than anything else on this list.

### 4.6 MTGJSON deck JSON ✅ (live API)

`https://mtgjson.com/api/v5/decks/<FileName>.json`, index at `DeckList.json`:

```json
{"data": {"code":"10E","name":"Arcanis's Guile","type":"Theme Deck","releaseDate":"2007-07-13",
          "mainBoard":[{"name":"Sage Owl","count":2,"isFoil":false,"number":"104","setCode":"10E",
                        "uuid":"…","identifiers":{"scryfallId":"…","mtgoId":"27422", …}}],
          "sideBoard":[], "commander":[], "displayCommander":[], "planes":[], "schemes":[],
          "tokens":[], "sealedProductUuids":[]}}
```

This is the richest schema of the lot, and its section names line up almost exactly with
mtg.wtf's `Deck` sections — unsurprisingly, since MTGJSON's deck files are built from
taw's own [magic-preconstructed-decks](https://github.com/taw/magic-preconstructed-decks),
the same source as this repo's `data/decks.json` ✅. So the vocabulary is already
familiar, and unlike any text format it can carry foil, etched, tokens, display
commander, and printings without ambiguity.

(`data/decks.json` itself — `{name, type, category, format, set_code, release_date,
cards: {"Main Deck": [{name, count, ...}], "Sideboard": [...]}}` ✅ — is a fifth
structured format mtg.wtf could emit essentially for free, though nothing outside these
two projects reads it.)

### 4.7 Scryfall deck JSON ⚠️

Scryfall's deck feature still exists (`/decks` redirects to sign-in ✅). Its export JSON is
a list of `deck_entry` objects with `section`, `count`, `raw_text`, `found`,
`printing_specified`, `finish`, and a `card_digest` (`name`, `set`, `collector_number`,
`scryfall_uri`, `image_uris`). Useful mainly as an *import* source; the sections are
`mainboard` / `sideboard` / etc.

### 4.8 MPCFill XML ⚠️

Proxy-printing orders: `<order><details><quantity>…<fronts><card><id>…<slots>0,5</slots>`.
Google-Drive image ids, not card identity — out of scope for mtg.wtf.

---

## 5. Collection CSV formats

These matter because a sealed pool is closer to a *collection* than a deck, and every
collection app imports CSV. Headers below verified ✅ against the reference fixtures in
[MtgCsvHelper](https://github.com/StepKie/MtgCsvHelper) (a project that exists solely to
convert between them, which is itself evidence of how unstandardised this is):

| Site | Header |
| --- | --- |
| Moxfield (binder) | `Count,Tradelist Count,Name,Edition,Condition,Language,Foil,Tags,Last Modified,Collector Number,Alter,Proxy,Purchase Price` |
| Moxfield (collection) | `Count,Name,Edition,Collector Number,Condition,Foil,Language,Purchase Price` |
| ManaBox | `Quantity,Name,Set code,Set name,Collector number,Condition,Foil,Language,Purchase price,Scryfall ID` (import also accepts `Binder Name`, `Binder Type`, `Rarity`, `ManaBox ID`, `Misprint`, `Altered`) |
| Archidekt | `Quantity,Name,Edition Code,Edition Name,Collector Number,Condition,Finish,Language,Purchase Price,Date Added,Scryfall ID` |
| Deckbox | `Count,Name,Edition Code,Edition,Card Number,Condition,Foil,Language,My Price,Scryfall ID` |
| Dragon Shield | `"sep=,"` line, then `Folder Name,Quantity,Trade Quantity,Card Name,Set Code,Set Name,Card Number,Condition,Printing,Language,Price Bought,Date Bought,LOW,MID,MARKET` (CRLF required) |
| MTGGoldfish | `Quantity,Card,Set ID,Set Name,Collector Number,Foil,Scryfall ID` |
| MTGO | `Quantity,Card Name,Set,Collector #,Premium` |
| TCGplayer | `Quantity,Simple Name,Set Code,Set,Card Number,Condition,Name,Printing,Language` |
| TopDecked | `QUANTITY,NAME,SETCODE,SETNAME,COLLECTOR NUMBER,CONDITION,FINISH,LANG,ACQUIRED PRICE,ID` |
| Card Kingdom | `title,edition,foil,quantity` (set *name*, not code) |
| CubeCobra | `name,CMC,Type,Color,Set,Collector Number,Rarity,Color Category,status,Finish,maybeboard,image URL,image Back URL,tags,Notes,MTGO ID,Custom` |

Common shape: quantity, name, set code, collector number, foil/finish, condition,
language, and very often a **Scryfall ID** column. Most of these importers accept a
Scryfall ID as the authoritative identifier, which sidesteps every set-code and
collector-number disagreement in this document.

mtg.wtf already computes Scryfall IDs (`index/scryfall_ids.txt`, 111,922 rows, written by
`indexer/lib/scryfall_ids_serializer.rb`) but the search engine does not load them at
runtime. Loading them costs memory on a memory-constrained box; see §7.

Finish values differ per site (`normal`/`foil`/`etched` for ManaBox; `Normal`/`Foil`/
`Etched`/`Rainbow Foil`/`Surge Foil`/… for Dragon Shield ✅). mtg.wtf tracks
foil and etched on `PhysicalCard` ✅, which is enough for the common three-value case.

---

## 6. Site APIs and links (no file involved)

### 6.1 SealedDeck.Tech ✅ (verified live)

The most directly useful finding for this issue, since the reporter's use case is
"open a booster box, then take the pool somewhere".

```
POST https://sealeddeck.tech/api/pools
{"sideboard": [{"name": "Shock", "set": "STX", "count": 1}, …], "poolId": "<optional, to extend>"}
→ {"poolId": "Spn1gh1WT7"}

GET https://sealeddeck.tech/api/pools/Spn1gh1WT7
→ {"poolId": "…", "sideboard": [{"name": "Hall of Oracles", "count": 1}, …]}
```

Verified by a live `GET` and by reading a client that posts to it
([booster-tutor](https://github.com/fverdoja/booster-tutor)). Name + set code + count;
no collector number, so specific printings are lost, and meld cards must be sent under
their front-face name. A "open this pool in SealedDeck.Tech" button on the sealed page is
one HTTP POST and a redirect.

### 6.2 Others

* **Archidekt** has a public read API (`archidekt.com/api/decks/<id>/` ✅ — returns JSON
  without auth) but deck creation needs auth.
* **Moxfield**'s API sits behind Cloudflare (a plain request gets a challenge page ✅);
  they gate access on an approved user agent arranged with them ⚠️. Assume no
  programmatic deck creation.
* **CubeCobra** exposes `cubecobra.com/cube/api/cubeJSON/<id>` ✅.
* **ManaBox** imports by URL from Aetherhub, Archidekt, Deckstats, Moxfield, MTGTop8,
  Scryfall, TappedOut, TCGplayer, Untapped ✅ — i.e. a stable public mtg.wtf deck URL is
  itself an interop surface, if those importers ever add mtg.wtf.
* **Frogtown / Tabletop Simulator**: TTS has no decklist format; converters take a plain
  or Arena list and emit a TTS saved-object JSON ❓.

---

## 7. Cross-cutting problems

### 7.1 Collector numbers per-face vs per-card — the core issue

mtg.wtf numbers each *face*: `woe 4a` Besotted Knight / `woe 4b` Betroth the Beast, both
mapping to the same Scryfall id ✅ (verified in `index/scryfall_ids.txt`). Scryfall — and
therefore Moxfield, Archidekt, ManaBox, Deckbox, TopDecked, Cockatrice's printing
resolver, and everything else built on Scryfall data — numbers the *physical card*: `woe 4`.
This is exactly what the reporter meant by "taking the `a`s off each double-sided card".

Naively stripping a trailing `a`/`b` is **wrong**. Of 4,983 suffixed printings in the
index, 847 have a unique Scryfall id ✅ — Alliances/Fallen Empires-style art variants
(`all 1a` / `all 1b` Carrier Pigeons) where Scryfall uses the same suffixed numbers.

The correct rule is available in-model: strip the face letter only when the printing is
part of a multi-face physical card, i.e. when `PhysicalCard#parts.size > 1`
(`search-engine/lib/physical_card.rb:118`) or `CardPrinting#has_multiple_parts?`. Meld
needs checking separately — Scryfall does give meld backs their own suffixed numbers ❓.

This one fix is a prerequisite for *any* Scryfall-ecosystem export, and is independent of
which formats get added.

### 7.2 Set codes

mtg.wtf's codes come from mtgjson, which tracks Scryfall closely but not perfectly, and
mtg.wtf carries `alternative_code` for magiccards.info codes
(`indexer/lib/patches/patch_set_codes.rb`). Codes to watch: Arena's remaps (`DAR`↔`DOM`
✅), The List / `plst` where the "real" set is encoded in the number (`PLST MH2-123`,
handled specially by Cockatrice ✅ and Archidekt ✅), Ravnica guild kits (Dragon Shield
invents `GK2_AZORIU` ✅), and token sets. For destinations that resolve by name first and
printing second (Moxfield, Archidekt, ManaBox ✅), a wrong set code degrades to "some
other printing", not to an error.

### 7.3 Foil / finish markers

`[foil]` (mtg.wtf) vs `*F*` (Moxfield, Archidekt, TappedOut, Cockatrice ✅, and stripped
by XMage's Arena importer ✅) vs a `Foil`/`Finish` column (all CSVs) vs nothing at all
(Arena, MTGO text, Cockatrice `.cod`). Etched is a fourth state that only the CSVs and
Moxfield express reliably ✅.

### 7.4 Sections

Beyond main/sideboard, formats disagree wildly: `Commander`, `Companion`, `Maybeboard`,
`Considering`, `Planes`, `Schemes`, `Conspiracy`, `Avatar`, `Attractions`, `Stickers`,
`Tokens`, `Display Commander`. mtg.wtf already models Main/Sideboard/Commander/
Planar/Scheme/Display Commander + tokens (`search-engine/lib/deck.rb:4`). Forge ✅ and
MTGJSON ✅ are the only targets that can carry all of them; text formats will drop
whatever they don't know, usually silently.

### 7.5 Card names

`//` vs `/` for split/DFC names (Cockatrice has an explicit "TappedOut split cards"
option that rewrites `//` to `/` ✅; XMage's MTGO importer rewrites `/` to ` // ` ✅);
front-face-only vs full name (Dragon Shield uses short names for transform and MDFC but
full names for adventure and split ✅); Un-set punctuation; accented names; tokens
("Beast" vs "Beast Token" — Moxfield rejects the decorated form ✅).

### 7.6 Encoding and line endings

BOM, CP1252, and CRLF all show up in the wild; `UserDeckPreprocessor` already handles them ✅.
Dragon Shield *requires* CRLF and a leading `"sep=,"` line ✅. Quote any field containing
a comma — ManaBox rejects unquoted `Valki, God of Lies // Tibalt, Cosmic Impostor` ✅.

---

## 8. Recommendation

taw's objection in the thread — "in theory I could add a 'Download as…' dropdown with 20
options, but I don't think any of them is really documented enough" — is fair for most of
this list. But the situation is better than 20 undocumented options: **one** line format
covers nearly every destination people actually named, and there are two or three
genuinely-specified extras worth having.

### Export: four options, not twenty

1. **mtg.wtf / XMage** — what exists now, unchanged. Keeps existing links and MythicHub working.
2. **Universal (Arena-style)** — `1 Card Name (SET) NUM` + `*F*`, sections `Deck` /
   `Sideboard` / `Commander`, no comments. Requires the §7.1 number fix. One format,
   read by Moxfield, Archidekt, Cockatrice, ManaBox, TappedOut, Deckstats, Scryfall,
   Draftmancer, TopDecked, MythicHub, Arena, and every proxy site. This alone closes the
   issue for both reporters.
3. **Plain names** — `1 Card Name`. The lowest common denominator (MTGO, Apprentice,
   Cockatrice, vendor mass entry, anything else). Trivial, already implemented as
   `to_text` for precons.
4. **CSV** — `Count,Name,Edition,Collector Number,Foil` (the Moxfield-collection header;
   ManaBox, Archidekt, Deckbox and Dragon Shield all accept close variants). This is the
   right shape for a sealed *pool*, which is a collection, not a deck.

Plus one non-file option that is arguably the best fit for the original use case:

5. **"Open in SealedDeck.Tech"** on the sealed page — a single POST (§6.1), returning a
   shareable pool link that people can then build and export from.

Deliberately excluded: Cockatrice `.cod` (its plain-text and Arena-style import already
work, and `.cod` can't carry printings anyway), MTGO `.dek` (needs CatIDs mtg.wtf doesn't
load), OCTGN, Lackey, MPCFill, MWS (legacy, tiny audiences). MTGJSON deck JSON and Forge
`.dck` are the two "if someone asks" candidates — both are fully specified and both can
carry mtg.wtf's exotic sections.

### Import: fix the parser, don't add file types

Ranked by how often it'll bite someone:

1. ~~`(SET) NUM` and `(SET) XXX-NUM` in `DeckParser#preparse`~~ — done, along with
   `*F*` / `*E*` markers, trailing `#tags`, and the `Deck` / `Mainboard` / `Companion` /
   `About` headers. Arena-style lists now import.
2. Deckstats sections as `//`-comments (`//Main`, `//Sideboard`, `//Maybeboard`) —
   the comment rule eats them before the header rule sees them.
3. Deckstats `[SET#NUM]` — the bracket parser only splits on `:` or `/`,
   so `[2XM#310]` currently resolves as a set code of `2XM#310`.
4. Disambiguate Archidekt's `[Category]` from `[SET]` — a bracket whose content isn't a
   known set code (and isn't `foil`) should be dropped, not treated as a set. Only
   matters for lines with no `(set) num`, which now takes precedence.
5. `Maybeboard` / `Considering` — needs a decision about where those cards go, not
   just a parser change.

All of these are line-parser changes in one file with spec coverage to extend
(`search-engine/spec/deck_parser_spec.rb`).

### Notes for implementation

* The face-number fix (§7.1) is the only piece with real subtlety. It belongs on
  `PhysicalCard` (something like `#printing_number`), not in each exporter.
* Scryfall IDs would make CSV export bulletproof, but `index/scryfall_ids.txt` isn't
  loaded at runtime and 112k ids is not free on a memory-constrained box. Set code +
  fixed collector number is good enough for every importer surveyed; leave the ids alone
  unless a concrete need appears.
* UI: the sealed page and the deck page both need this, and taw doesn't want more
  buttons. A `<select>` of formats next to the existing download button (or a `?format=`
  parameter on the existing download routes, `frontend/config/routes.rb:19`) keeps it to
  one control.
* Exports are pure functions of a `Deck` / card list, so they belong in the search engine
  next to `PreconDeck#to_text`, with the controllers just choosing one.

---

## 9. Open questions

* Does Moxfield's *text* export mark etched foils, and with what? (`*E*` is a guess.)
* Does Archidekt's text import really ignore collector numbers today, or is that stale
  forum lore? If it honours them, option 2 needs no Archidekt-specific variant at all.
* Meld: does Scryfall suffix meld backs' collector numbers, and does mtg.wtf agree?
* Do the vendor mass-entry parsers (TCGplayer, Card Kingdom) tolerate a trailing `*F*`
  or a `(set) num` they don't recognise? Determines whether "buy this pool" is free.
* Forge's current section list — does it now include `[Commander]` and `[Dungeon]`?

## Sources

Primary (read directly): [XMage deck importers](https://github.com/magefree/mage/tree/master/Mage/src/main/java/mage/cards/decks/importer),
[Cockatrice deck_list.cpp](https://github.com/Cockatrice/Cockatrice/blob/master/libcockatrice_deck_list/libcockatrice/deck_list/deck_list.cpp),
[Cockatrice deck_file_format.h](https://github.com/Cockatrice/Cockatrice/blob/master/cockatrice/src/interface/deck_loader/deck_file_format.h),
[Forge DeckSerializer](https://github.com/Card-Forge/forge/blob/master/forge-core/src/main/java/forge/deck/io/DeckSerializer.java) and a live `.dck`,
[MTGJSON deck API](https://mtgjson.com/api/v5/decks/ArcanisSGuile_10E.json),
[SealedDeck.Tech API](https://sealeddeck.tech/api/pools/Spn1gh1WT7) and [booster-tutor](https://github.com/fverdoja/booster-tutor/blob/main/boostertutor/utils/utils.py),
[Draftmancer cube format](https://draftmancer.com/cubeformat.html),
[MtgCsvHelper sample CSVs + SITE_BEHAVIOR.md](https://github.com/StepKie/MtgCsvHelper/tree/main/MtgCsvHelper/Resources/SampleCsvs).

Secondary: [silhouette-card-maker MTG plugin](https://github.com/Alan-Cha/silhouette-card-maker/blob/main/plugins/mtg/README.md),
[Cockatrice deck list import wiki](https://github.com/Cockatrice/Cockatrice/wiki/Deck-List-Import-Formats),
[MagicArena Wiki: Deck Import](https://magicarena.fandom.com/wiki/Deck_Import),
[ManaBox import/export guide](https://www.manabox.app/guides/decks/import-export/),
[TCGplayer Mass Entry help](https://help.tcgplayer.com/hc/en-us/articles/360055768913-Getting-Started-With-Mass-Entry),
[Archidekt forum threads on import](https://archidekt.com/forum/thread/2946960),
[TappedOut formatting help](https://tappedout.net/help-desk/formatting/),
plus the discussion in issue #348 itself.

# Limited format data gaps

Research notes for [issue #293](https://github.com/taw/magic-search-engine/issues/293)
("Support for Limited formats"), covering the two remaining data checkboxes: "fill data
gaps" and "for old and nonstandard sets, double check that data is correct".

This document is a survey, not a plan. It records what `data/limited_formats/` is
missing, how confident I am about each gap, and what it would take to close it. Nothing
here has been implemented.

Gaps are deleted from this file as they are closed, and whatever was learned closing them
goes into `data/limited_formats/` next to the data it explains — the README for
anything general, a comment in the set’s own file for anything per-set. So this file is always the
open work, never a changelog.

`search-engine/spec/limited_format_coverage_spec.rb` passes clean (10 examples, 0
failures), so every gap below is something the coverage check *deliberately does not
look for* — it only asks for formats a set's own boosters imply.

Verification markers used throughout:

* ✅ — verified against data in this repo, or a primary WotC source
* ⚠️ — secondhand (mtg.wiki, forum posts); shape is probably right, details may drift
* ❓ — plausible but unconfirmed; do not enter into the yaml without checking

---

## 1. `sealed` before the six-booster era

The tournament-pack era is filled in — `usg` (1998) through `ala` (2008), 33 sets, one
tournament pack plus two boosters, with the pack selection taken from Grand Prix fact
sheets. Sources are in `data/limited_formats/README.md` and in `tsp.yaml` and `fut.yaml`,
which are the two events that pin the composition down.

❓ What is left is the sets that had no tournament pack of their own:

* `csp` — Ice Age block predates tournament packs, so a Coldsnap sealed event cannot have
  used one. Its prerelease was five boosters, but that does not say what an ordinary event
  handed out.
* `7ed` `8ed` `9ed` `10e` — core sets stopped getting tournament packs after Sixth Edition,
  and their boosters gained a land slot instead. What core set sealed used is unknown.
* `mir` (1996) through `exo` (1998) — the starter-deck era, 60-card starter decks rather
  than 75-card tournament packs, unsourced. `-starter` boosters exist for
  `lea leb 2ed 3ed 4ed ice mir 5ed tmp` whenever it is closed.

## 2. Nothing at all before Mirage

✅ Measured: sets with boosters and no `data/limited_formats/` file, pre-1996:

| Sets | Boosters we have |
| --- | --- |
| `lea` `leb` `2ed` `3ed` `4ed` `ice` | booster + `starter` |
| `arn` `atq` `leg` `drk` `fem` `chr` `hml` `all` | booster only |
| `sum` `ren` `rin` | booster only (non-tournament products) |
| `por` `p02` `ptk` `s99` | booster only |

`LimitedFormatCoverage::DRAFT_BOOSTERS` maps only `draft`/`play`/`mtgo`/`arena` variants,
so a bare `<set>` booster expects nothing, and the comment says drafting these "was never
an event WotC ran".

⚠️ That is roughly right for *sanctioned* play — [mtg.wiki
Mirage](https://mtg.wiki/page/Mirage) calls Mirage "the first set that was developed with
Limited play (sealed deck and draft) in mind", and the first Rochester-draft Pro Tour is
PT LA 1997 — but sealed deck was played at events from 1994, and Rochester draft itself
dates to a Rochester, NY convention in late 1993/early 1994.

**Recommendation:** this is a boundary decision, not missing data. Whichever way it goes,
write it down — right now it lives only in a code comment, and
`data/limited_formats_not_played.yaml` structurally cannot hold it (the coverage check
never expects these formats, so entries there would fail the "only lists formats we'd
otherwise expect" example).

## 3. Prereleases that happened and are not in the data

These do not warn because the check only expects `prerelease-sealed` where a
`<set>-prerelease` booster exists, and all of these predate seeded prerelease packs.

* ✅ **`tmp` `sth` `exo`** — promos in the db as `ptmp` (`Dirtcowl Wurm`), `psth`
  (`Revenant`), `pexo` (`Monstrous Hound`), so we know the events happened. Pool ❓ and
  looking increasingly unreachable: the fact sheets start in late 2005, the primers in 2003,
  and neither `wizards.com/default.asp?x=mtgcom/events/*` nor `?x=mtgevent/*` has anything
  archived for a set this old. A domain-wide Wayback regex search is the only thing left
  untried, and the CDX API times out on it. Any answer will probably have to come off paper
  — a 1997 Duelist, or a period tournament organizer's kit.
* ⚠️ **`mir` `vis` `wth`** — prereleases happened (Mirage's was the first ever), but there
  were no prerelease cards, and the pools are likely unrecorded anywhere.
  [mtg.wiki Prerelease card](https://mtg.wiki/page/Prerelease_card): "They were first
  introduced at the Tempest prerelease in October 1997."
* ❓ **`ptk`** — `pptk` (`Lu Bu, Master-at-Arms`) exists, but it was a regional event promo
  rather than a normal prerelease giveaway. Needs a judgement call before entry.

## 4. Core sets 5ed–10e have no prerelease — and that is probably correct

✅ `5ed 6ed 7ed 8ed 9ed 10e` have `draft` only. The earliest core-set prerelease promo in
the db is `pm10` (`Vampire Nocturnus`, 2009), and `m10` is the first core set with a
`prerelease-sealed` entry. So the absence looks right, not missing.

Same structural problem as gap 2: this is invisible knowledge that
`limited_formats_not_played.yaml` cannot record. Worth a comment in
`data/limited_formats/README.md` so nobody re-researches it.

## 5. Products with boosters and no format entry

✅ Measured (excluding the pre-1996 rows in gap 2, and the sets already covered by
`limited_formats_not_played.yaml`):

* `clu` — Ravnica: Clue Edition, a sealed-based murder mystery product with its own rules.
* `who` `pip` `acr` — collector boosters only; no limited play. Candidates for documenting
  as "never had a format" if we ever widen the coverage check.
* `ss1` `ss2` `ss3` `zne` `sld` `slc` — not tournament products at all.
* ✅ `ugin` is a false positive: `ugin-fate` is already handed out by the `frf`
  prerelease pools.

❓ Jumpstart on Arena is the one part of Jumpstart still unmodelled. Paper Jumpstart is in
`data/limited_formats/` now, but `j21` (Jumpstart: Historic Horizons) and `ajmp` (Jumpstart
Arena Exclusives) are Arena-only and have no boosters in the db at all, so there is nothing
to point a format at. Arena also builds its packs its own way, so it would be a digital
format of its own, the way `arena-draft` is — booster data first, format second.

## 6. Formats the schema has no room for

These were real DCI-sanctioned events. None of them fit the current
set → format → booster-list shape, so each needs a schema decision before any data entry
is worth doing.

* ⚠️ **Rochester draft** — [mtg.wiki Rochester Draft](https://mtg.wiki/page/Rochester_Draft)
  lists it as the competitive draft format at Pro Tour / Nationals / Worlds from 1997 to
  2006, with per-event set lists. Some of those pack combinations never existed as a store
  draft, e.g. PT LA 1997 was 2× Mirage + 1× Visions and PT Nagoya 2005 was 3× Champions of
  Kamigawa. A team variant ran from the 1999–00 season.
* ⚠️ **Team Sealed / Team Draft** — [mtg.wiki Team events](https://mtg.wiki/page/Team_Sealed):
  Team Sealed is 12 boosters shared across three players. Pro Tours every year 1999–2005,
  Grand Prix 2000–2005 and 2012–2019. Pools are per *team*, which is the shape `bbd`
  already uses.
* ⚠️ **Two-Headed Giant sealed** — prereleases and GPs from the mid-2000s, also per-team.
* ⚠️ **Starter-deck-era sealed** — see gap 1; a distinct product from tournament packs and
  worth modelling separately if gap 1 is ever closed.
* ❓ **Solomon / Winston / Winchester / Grid draft** — two-player formats, mostly casual
  rather than sanctioned; probably out of scope.
* ⚠️ **MTGO flashback drafts** — old paper sets drafted on Magic Online out of the original
  boosters. Related to the open "flag to indicate supported games" checkbox on #293 rather
  than to missing data.

## 7. Old draft orders: spot check

✅ Every pre-2010 `draft` entry follows the block rules stated in the yaml header
(new set appended last until Mirrodin Besieged), and
[mtg.wiki Booster Draft](https://mtg.wiki/page/Booster_Draft) agrees on the reversal point
and on the later Two-Block / Three-and-One changes. `vis` MIR/MIR/VIS, `wth` MIR/VIS/WTH,
`dis` RAV/GPT/DIS, `fut` TSP/PLC/FUT etc. all check out.

❓ One to confirm rather than assume: `shm` SHM/SHM/SHM and `eve` SHM/SHM/EVE. Shadowmoor
was a large set opening its own block half, and the Eventide-era format is sometimes
written the other way round.

## 8. Unsourced prerelease pools

Every prerelease pool the Worldwide Prerelease Fact Sheets and the primers cover is now
sourced in its own file, and the fact sheet series is exhausted — see
`data/limited_formats/README.md` for where they live and how to list them.

❌ The sheets stop in early 2007 and restart in September 2008, and no primer survives from
before 2003, so nine sets have no reachable source at all:

* ❓ **`usg` `mmq` `inv` `ody` `ons` `chk` `rav`** — large sets entered as tournament pack +
  three. Large sets got two between 2003 and 2007, so these are probably a booster too
  generous, but Shards of Alara (2008) got three, so the rule cannot be applied unsourced.
  Each file carries a comment saying so.
* ❓ **`shm`** — the primer says two *or* three at the organizer's discretion, and no fact
  sheet is archived for April 2008. Entered as three; there may be no better answer.
* ❓ **`eve`** — July 2008, the one month between the two fact-sheet runs. No primer either.

❓ The small sets `ulg` `uds` `nem` `pcy` `pls` `apc` `tor` `jud` `bok` are unsourced too.
Three is very likely right — every small set with any source says three — but none of them
is confirmed, and they are all pre-2003.

Tried and dead, so nobody repeats it: the old site's own event pages. Everything under
`wizards.com/default.asp?x=mtgcom/events/` is archived from February 2006 at the earliest,
its per-set prerelease pages exist only for `fut`, `lor` and `mor` (all 2007), and
`?x=mtgevent/*` has nothing prerelease-related at all. Grand Prix fact sheets do print pools
(that is where gap 1's composition came from) but the archived ones are 2006-2007 and 2015+;
the 2000-era ones that survive are event logistics with no product line.

---

## Suggested priority

1. Write down the two deliberate boundaries — pre-Mirage silence, and core sets having no
   prerelease before M10 (gaps 2 and 4).
2. Team / Rochester / 2HG — schema decision first, data entry second (gap 6).

The pool research (gaps 1, 3 and 8) is not on this list any more: every source that is
online has been used, and what is left needs paper sources rather than more searching.

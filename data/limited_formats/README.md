# Limited formats

One file per set, named `{set_code}.yaml`, the same convention `data/boosters/` uses. The
set code comes from the file name, so a file contains that set's formats at the top level
and nothing else:

```yaml
# Betrayers of Kamigawa, drafted with two Champions boosters.
prerelease-sealed:
  boosters:
  - 1x chk-tournament
  - 3x bok-draft
  unplayable-promo:
  - Ink-Eyes, Servant of Oni [PBOK:66★] [foil]
draft:
- chk-draft
- chk-draft
- bok-draft
```

One set has to break the naming rule: Conflux is `con_.yaml`, because CON is a reserved
device name on Windows and a file called `con.yaml` cannot be checked out there. Underscores
in a file name are stripped to get the set code, so that is the escape hatch if it ever
happens again — `data/boosters` does the same thing.

`indexer/bin/limited_formats_indexer` compiles the whole folder into a single
`index/limited_formats.json`, which is what the search engine reads. Sets that had the
boosters for a format but never had the format go in `data/limited_formats_not_played.yaml`
instead, one line each saying why.

Anything hard-won about a particular set — which primer a pack count comes from, why a pool
looks odd — belongs in a comment in that set's file, next to the data it explains. This
README is only for what applies to every set. Open questions and known-wrong data are
tracked in [DATA_GAPS.md](../../DATA_GAPS.md).

## Keys

| Key | Meaning |
| --- | --- |
| `draft` | the three booster packs, in the order they are opened |
| `sealed` | the sealed deck pool (unordered, so counts are used) |
| `prerelease-sealed` | the sealed deck pool handed out at that set's prerelease |
| `play-variant` | how the set is played, when that is not normal limited |

A draft or an Arena draft that needs a title and explanation of its own — a set whose
Arena boosters changed between runs has one numbered format per run, `arena-draft-1` and
friends — is a hash of `boosters` plus `name` and `description` rather than a bare list.

## Play variants

Nearly every set is drafted eight players / three packs / 40-card deck / 1v1, and sealed as
a 40-card deck out of six boosters. The handful of sets built for something else carry a
`play-variant` key, which applies to every limited format listed for that set. (This is
unrelated to the `variants` key inside a sealed pool, which is about which pool a player
got, not how it is played.)

* `multiplayer` — Conspiracy: drafted with draft-matters cards (and conspiracies, drafted
  face down and starting the game in the command zone), played as free-for-all multiplayer.
* `two-headed-giant` — Battlebond: drafted in fixed pairs and played 2HG, which is what the
  partner pairs in the booster are for. Packs of such a set are listed per team, not per
  player, as that is how they are handed out.
* `commander` — Commander Legends and friends: three 20-card packs drafted into a 60-card
  singleton deck with a commander, played in multiplayer pods.
* `pick-two` — Through the Omenpaths on Arena: two cards are taken from every pack instead
  of one, so three 14-card packs are drafted seven picks at a time into a 42-card pool.

Sets whose *contents* are unusual but whose play is ordinary are not tagged: the Un-sets,
Mystery Booster, and Innistrad: Double Feature are all just normal drafts over a strange
card pool.

## Draft order

Block drafts originally added each new set to the *end* of the order, so a block's draft
went large set first (RAV / GPT / DIS, TSP / PLC / FUT). Beginning with Mirrodin Besieged
the order was reversed and drafts start with the most recent set (MBS / SOM / SOM,
NPH / MBS / SOM). https://mtg.wiki/page/Booster_Draft#Order

From Oath of the Gatewatch on, the Two-Block Paradigm drafted the second set of a block as
BBA (two small, one large) rather than AAB. From Dominaria on (Three-and-One Model) every
set is drafted on its own.

## Sealed pools

Until Conflux, sealed was one tournament pack plus two boosters; from Alara Reborn on it is
six boosters. The [Morningtide primer](https://magic.wizards.com/en/news/feature/morningtide-prerelease-primer)
says both numbers in one sentence, which is the only official statement of the old one we
have found:

> you will get one *Lorwyn* tournament pack and *three* Morningtide boosters to create a
> deck (Sealed Deck tournaments usually provide only two boosters, but it's the
> Prerelease!)

A tournament pack is 75 cards, 45 playable plus 30 basic lands. The DCI priced one at three
boosters, in the Two-Headed Giant recommendation of "one tournament pack and four boosters
or seven boosters" ([Magic DCI Floor Rules effective 2006-12-20](https://web.archive.org/web/20071231072040/http://www.wizards.com/dci/downloads/MTG_FLR_1Dec06_EN.txt),
section 170).

Don't go looking for this in the rules documents — it isn't there. The Magic DCI Floor
Rules (checked 2002, 2004-09, 2004-12, 2005-08, 2006-12, 2009-01, 2009-04) and the DCI
Universal Tournament Rules (2004-06, 2006-01, 2006-12, 2007-06) recommend product for team
and Two-Headed Giant events only; for an individual the UTR says just "each player receives
an assortment of sealed product". They are all on the Wayback Machine under
`wizards.com/dci/downloads`.

The `sealed` key is only filled in for the six-booster era so far. The starter-deck era
before Urza's Saga (60-card starter decks, not 75-card tournament packs) is a different
thing again, and is unsourced.

## Prereleases

Tournament-pack era prereleases were one tournament pack plus boosters, and the count
depends on the size of the set: a small set handed out the block's large-set tournament pack
plus **three** boosters of the new set, a large set its own tournament pack plus **two** of
its own — the same pool as an ordinary sealed event. The quotation each set's pool comes
from is in a comment in that set's file. Sets with no such comment are unverified: their
primer either predates the ones that survive online (2003) or isn't at a findable URL, and
they are entered as tournament pack plus three, which is a guess for the large ones.

Three things stop this from being a rule you can apply blind. Shards of Alara is a large
set that handed out three; Shadowmoor was "one tournament pack, and either two or three
*Shadowmoor* boosters, depending on your tournament organizer"; and Dissension notes "there
might be some parts of the world where you only get two packs, but by and large it is
three". So each set wants its own source rather than a bulk edit.

The best source is WotC's **Worldwide Prerelease Fact Sheet** for the set, which states the
product mix outright, for single players and for Two-Headed Giant and three-person teams.
They are all dead on the live site and all present on the Wayback Machine, at
`magic.wizards.com/en/articles/archive/[<set>-]worldwide-prerelease-fact-sheet-<date>` up to
early 2007, and at `wizards.com/Magic/TCG/Events.aspx?x=mtgcom/events/prerelease-facts` from
September 2008. Nothing of the sort is archived before late 2005. List what exists with the
CDX API — a prefix query works, a regex filter times out:

```
http://web.archive.org/cdx/search/cdx?url=magic.wizards.com/en/articles/archive/<name>*&output=text&fl=original&collapse=urlkey
```

The prerelease card was a fixed giveaway and not part of the sealed pool until Return to
Ravnica, which is where `unplayable-promo` gives way to `playable-promo`. Core sets kept the
old fixed promo through Magic 2014. From Khans of Tarkir on the promo is a random
rare/mythic of the set, and it ships inside the seeded prerelease booster — where that is
the case it is part of the booster's contents and is not listed separately.
https://mtg.wiki/page/Prerelease_card

Promo cards carry a `[foil]` tag when the card was handed out foil, and no tag when it was a
normal card. None were available both ways. There are two sources for this: the wiki page
above, which calls out the non-foil ones in its comments, and the printing's own foiling in
the card db, which is `foilonly` or `nonfoil` for every one of them. The two agree on every
promo listed here (all foil — the non-foil prerelease cards are Tempest, Stronghold, Exodus
and Portal Three Kingdoms, none of which have a pool listed). Where they ever disagree, tag
the entry with what the wiki says and leave a comment in that set's file saying so; the
loader warns about the mismatch either way.

## Play Boosters

Ravnica Remastered was the last set with draft boosters; from Murders at Karlov Manor on
there is a single `<set>-play` booster, and draft and sealed use it in the same counts draft
boosters used to (three to draft, six to seal).
https://magic.wizards.com/en/news/making-magic/what-are-play-boosters

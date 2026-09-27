# Astrology Lands bonus model

All twelve signs use the same ordinary pool of **40 Jumpstart-style SLD basics, 540–579**, plus the first Blueprint family **603–607**. This is a maintainer-approved shared-pool inference, not a claim that all 45 printings have been observed in every sign. The master ledger’s observation matrix remains narrower than executable membership intentionally.

Research combined filmed openings, written firsthand reports, MTG Wiki, Magic Librarities, retailer descriptions, 29 user-supplied TikTok screenshots/links, and the comments/replies of 35 YouTube sources (200 displayed comments/replies). Possible cross-platform reposts and repeated reports are not independent samples. TikTok videos could not be independently replayed; screenshot identities and user-supplied drop attribution are distinguished in the master ledger.

Every sign has multiple ordinary outcomes. The observations overlap across release windows: Plains 543 occurs in Pisces, Taurus and Virgo; Mountain 564 in Taurus, Virgo, Scorpio and Sagittarius. First-family Blueprints are supported in seven signs (Gemini, Cancer, Virgo, Libra, Scorpio, Capricorn and Pisces), spanning the release year. These scattered observations support a shared pool better than treating sparsely sampled subsets as exhaustive per-sign distributions. At the adopted 7% Blueprint chance, even ten independent openings have about a 48% chance of containing no Blueprint; absence in a few reviewed openings is weak exclusion evidence. The reviewed sources are self-selected, so this calculation illustrates sampling limitations rather than estimating odds from the videos.

The full 40-card ordinary family, rather than only the observed union, and Blueprint eligibility for the other five signs are explicit modeling assumptions. They can be revised if actual collation evidence establishes a boundary. This exception is specific to the researched Astrology series; it does not reinstate the retired date-wide Secret Lair fallback pools.

### Timing and production limits

[Wizards' announcement](https://magic.wizards.com/en/news/announcements/secret-lair-whats-your-sign) describes monthly preorders, continued availability through the year and replenishment printing for drops selling out before December 23, 2022. The drops were not all shipped together after year-end. The [published delivery schedule](https://jeudecarte.net/magic/secret-lair-2022) suggests research cohorts of April–May (Capricorn/Aquarius), July (Pisces/Aries), September (Taurus/Gemini), October–November (Cancer/Leo/Virgo/Libra), and December (Scorpio/Sagittarius). These are scheduled delivery windows, not verified manufacturing batches. Capricorn already had a [May 2022 Blueprint and Hive report](https://www.reddit.com/r/magicTCG/comments/uje6x7/).

Blueprint observations span every cohort and use the same first family. Overlapping availability and possible replenishment mean preorder dates cannot establish distinct bonus runs; a late video may show older stock. There is no supported temporal cutoff for separate ordinary/Blueprint pools, so the implementation does not invent one.

### Additional chase membership and weights

| Signs | Ordinary lands | Blueprints | Additional chase category |
|---|---|---|---|
| Aries, Taurus, Gemini, Cancer, Leo, Virgo, Scorpio, Sagittarius, Aquarius | 93% total; 2.325% each | 7% total; 1.4% each | None modeled |
| Libra, Capricorn | 91% total; 2.275% each | 7% total; 1.4% each | 2% total: Petitioners 593 and Hive 668, 1% each |
| Pisces | 91% total; 2.275% each | 7% total; 1.4% each | Hive 668 at 2% |

Every category competes for **one foil bonus slot**. Equal weights within categories, 7% total Blueprints and 2% total additional chase are documented modeling estimates, not official or measured rates. Adding a supported chase reduces the ordinary category; it does not reduce the 7% Blueprint chance or add a second card.

Hive/Petitioners are not generalized to all signs. Capricorn has firsthand Hive and Blueprint reports plus a pictured Petitioner; Libra has filmed Hive and Petitioners; Pisces has an explicit firsthand written Hive report with lower evidentiary strength than a filmed reveal. Aquarius's Librarities-only Petitioner attribution is retained as an unresolved lead and **excluded from executable membership**, not declared false. No other sign receives those chases. Creature Slivers, second-family Blueprints and other Petitioners are excluded for lack of attributable evidence.

## Source ledger

The [master evidence ledger](https://github.com/mtgjson/mtg-sealed-content/blob/main/data/notes/sld-astrology-research.md) contains the per-sign observations, exact printing identifications, preserved screenshots, source exclusions and complete video-comment review. It is maintained with the sealed products; this document describes the executable model rather than duplicating the research history.

Representative direct evidence: [Gemini Blueprint](https://www.youtube.com/watch?v=WKMGv9CyhBk&t=136s), [Pisces Blueprint and written Hive report](https://www.youtube.com/watch?v=a1mQ_G-BnqU&lc=UgwMVQoMlYRkgv_eCVN4AaABAg), [Libra Hive](https://www.youtube.com/watch?v=tq34tYL5u04&t=9s), [Libra five-box opening including two Petitioners](https://www.youtube.com/watch?v=CD068TDAY7w), [Capricorn Petitioner photo](https://www.reddit.com/r/magicTCG/comments/ujafu5/new_persistent_petitioners_from_secret_lair/). [Aquarius checklist-only Petitioner lead](https://www.magiclibrarities.net/1517-rarities-secret-lair-drop-series-promos-english-cards-persistent-petitioners-promos-2021-2023.html) remains unimplemented.

Each `sld-bonus-astrology-<sign>` definition is one foil bonus shared by the two product editions. The sealed companion references these codes and counts five main lands plus one bonus. There are no changes to other Secret Lair pools.

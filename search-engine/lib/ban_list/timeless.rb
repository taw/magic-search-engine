require_relative "historic"

BanList.for_format("timeless") do
  # Timeless has never banned anything - "basically no bans" is the whole point
  # of the format - so everything below is either a restriction or a card that
  # can't be put in a deck in the first place.
  #
  # Conjurable/specialized is a property of the card on Arena rather than of any
  # one format's ban list, and Timeless and Historic have the same pool, so this
  # is Historic's list rather than a third hand-maintained copy of the same 114
  # names. Lightning Bolt is the one card that has to come back out: Historic
  # files it as conjurable because it's pre-banned there anyway, but it's an
  # ordinary craftable card (STA, FCA, TLE, MSC) and legal in Timeless.
  format_start(
    "Cards which can only be conjured or specialized into, never put in a deck",
    BanList["historic"]
      .full_ban_list(nil)
      .select{|_card, status| ["conjurable", "specialized"].include?(status)}
      .except("Lightning Bolt"),
  )

  change(
    "2023-12-12",
    "https://magic.wizards.com/en/news/mtg-arena/introducing-timeless-a-new-mtg-arena-format",
    "Channel" => "restricted",
    "Demonic Tutor" => "restricted",
    "Tibalt's Trickery" => "restricted",
  )

  change(
    "2026-02-09",
    "https://magic.wizards.com/en/news/announcements/banned-and-restricted-february-9-2026",
    "Necropotence" => "restricted",
  )
end

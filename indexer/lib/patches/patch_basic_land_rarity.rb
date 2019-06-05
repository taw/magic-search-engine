# MTGJSON v4 completely abandoned basic rarity,
# and it was buggy in v3 [ https://github.com/mtgjson/mtgjson/issues/462 ]
class PatchBasicLandRarity < Patch
  def call
    basic_land_names = [
      "Mountain",
      "Plains",
      "Swamp",
      "Island",
      "Forest",
      "Snow-Covered Mountain",
      "Snow-Covered Plains",
      "Snow-Covered Swamp",
      "Snow-Covered Island",
      "Snow-Covered Forest",
    ].to_set

    each_printing do |card|
      next unless basic_land_names.include?(card["name"])

      # First reset all to basic by default
      if card["rarity"] == "common"
        card["rarity"] = "basic"
      end

      # Now fix exceptions

      # Fix rarities of promo basics
      # Should this just check for set type promo ?
      if %W[
        parl pal00 pal01 pal02 pal03 pal05 pal06 pgru pjgp pelp palp ppre
        pmps pmps06 pmps07 pmps08 pmps09 pmps10 pmps01 prw2 prwk pss2 pss3
        pf19 j14 pal04 pmps11 pal99 g17 pdgm pgpx
      ].include?(card["set_code"])
        card["rarity"] = "special"
      end

      # Arabian Night Mountain is just a common
      if card["set_code"] == "arn"
        card["rarity"] = "common"
      end

      # As far as I can tell, Unglued basics were printed on separate black-bordered sheet
      # contrary to what Gatherer says
      # (this is already reset above, double set just for clarity)
      if card["set_code"] == "ugl"
        card["rarity"] = "basic"
      end
    end

    # For separate patch, ME4 Urza lands
    urza_lands = [
      "Urza's Mine",
      "Urza's Power Plant",
      "Urza's Tower",
    ].to_set
    each_printing do |card|
      next unless card["set_code"] == "me4"
      next unless urza_lands.include?(card["name"])
      card["rarity"] = "basic"
    end
  end
end

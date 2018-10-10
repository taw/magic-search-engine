# https://github.com/mtgjson/mtgjson/issues/462
class PatchBasicLandRarity < Patch
  def call
    basic_land_names = ["Mountain", "Plains", "Swamp", "Island", "Forest"]

    each_printing do |card|
      next unless basic_land_names.include?(card["name"])

      # Fix rarities of promo basics
      if %W[arena guru jr euro apac ptc].include?(card["set_code"])
        card["rarity"] = "special"
      end

      # As far as I can tell, Unglued basics were printed on separate black-bordered sheet
      # contrary to what Gatherer says
      if card["set_code"] == "ugl"
        card["rarity"] = "basic"
      end

      # Arabian Night Mountain is just a common
      if card["set_code"] == "arn"
        card["rarity"] = "common"
      end
    end
  end
end

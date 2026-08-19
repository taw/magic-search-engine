# Translate mtgjson's field names and value formats into ours.
#
# Nothing here should be about a specific card or set - that belongs in
# PatchMtgjsonBugs, PatchCardNames, or a patch of its own.

class PatchMtgjsonFields < Patch
  # mtgjson's older names for the layouts we use
  LAYOUTS = {
    "modal_dfc" => "modaldfc",
  }.freeze

  # Fields that only get renamed, camelCase to underscore_case.
  # `digital` is deliberately not set-based - there are Arena-specific fixed art
  # cards, and set-based logic has no way of finding cards like znr/288b.
  RENAMED_FIELDS = {
    "attractionLights" => "attraction_lights",
    "borderColor"      => "border",
    "flavorText"       => "flavor",
    "frameEffects"     => "frame_effects",
    "isFullArt"        => "fullart",
    "isOnlineOnly"     => "digital",
    "isOversized"      => "oversized",
    "isStorySpotlight" => "spotlight",
    "isTextless"       => "textless",
    "isTimeshifted"    => "timeshifted",
    "promoTypes"       => "promo_types",
    "securityStamp"    => "stamp",
  }.freeze

  # Same, except we only want them when true
  RENAMED_FLAGS = {
    "isGameChanger" => "game_changer",
    "isReserved"    => "reserved",
  }.freeze

  # These sets are not real Magic cards, so paper/mtgo/arena don't apply
  NONTRADITIONAL_SETS = %W[CEI CED 30A].freeze

  def call
    each_printing do |card|
      RENAMED_FIELDS.each do |from, to|
        card[to] = card.delete(from) if card.has_key?(from)
      end
      RENAMED_FLAGS.each do |from, to|
        card[to] = true if card.delete(from)
      end

      card["mv"] = mana_value(card)
      card["mana"] = card.delete("manaCost")&.downcase
      card["layout"] = LAYOUTS.fetch(card["layout"], card["layout"])
      card["etched"] = true if card["finishes"]&.include?("etched")

      normalize_availability(card)
      normalize_multiverseid(card)
      extract_flavor_name(card)

      # mtgjson uses [] where we want the field gone
      card.delete("supertypes") if card["supertypes"] == []
      card.delete("subtypes") if card["subtypes"] == []

      # This is text because of some X planeswalkers
      # It's more convenient for us to mix types
      card["loyalty"] = card["loyalty"].to_i if card["loyalty"] =~ /\A\d+\z/
      card["keywords"] = card["keywords"].map(&:downcase) if card["keywords"]

      # At least for now:
      # "123a" but "U123"
      card["number"] = card["number"].sub(/(\D+)\z/){ $1.downcase } if card["number"]

      card.delete("language") if card["language"] == "English"

      # redundant with types/subtypes/supertypes, just predelete
      card.delete("type")
    end
  end

  private

  def mana_value(card)
    mv = card.delete("convertedManaCost")
    face_mv = card.delete("faceConvertedManaCost")

    if face_mv
      case card["layout"]
      when "split", "aftermath", "adventure", "prepare"
        mv = face_mv
      when "transform"
        # ignore because
        # https://github.com/mtgjson/mtgjson/issues/294
      else
        if mv != face_mv
          warn "#{card["layout"]} #{card["name"]} has face mv #{face_mv} != mv #{mv}"
        end
      end
    end

    mv = mv.to_i if mv.to_i == mv
    mv
  end

  # Moved into "availability" in v5.
  # shandalar data is incorrect in mtgjson, so we do not want it, we do our own
  # calculations. dreamcast data is incorrect too, there's no replacement on our side.
  def normalize_availability(card)
    card["arena"] = true if card["availability"]&.delete("arena")
    card["paper"] = true if card["availability"]&.delete("paper")
    card["mtgo"] = true if card["availability"]&.delete("mtgo")

    # This logic changed at some point, I like old logic better
    if card["oversized"] or NONTRADITIONAL_SETS.include?(card["setCode"]) or card["border"] == "gold"
      card["nontraditional"] = true
      card.delete("arena")
      card.delete("paper")
      card.delete("mtgo")
    end
  end

  # Moved into "identifiers" in v5, which also makes it a String
  def normalize_multiverseid(card)
    multiverseid = card["identifiers"]&.delete("multiverseId") or return
    card["multiverseid"] = multiverseid.to_i
  end

  # for some reason mtgjson started using these fields for foreign names, which makes NO SENSE WHATSOEVER
  # and there's some unrelated bug that make it mix printed* and flavor* randomly
  def extract_flavor_name(card)
    return unless card["printedName"] or card["facePrintedName"] or card["flavorName"] or card["faceFlavorName"]

    if card["language"] == "English"
      # OK
      card["flavor_name"] = card.delete("faceFlavorName") || card.delete("flavorName") || card.delete("facePrintedName") || card.delete("printedName")
    elsif card["language"] == "Japanese"
      # Total bullshit going on here
      # Only take it if it's actually English
      card["flavor_name"] = [card["facePrintedName"], card["printedName"], card["faceFlavorName"], card["flavorName"]].compact.grep(/[a-z]/i).first
    else
      # 100% of this is garbage
      card.delete("facePrintedName")
      card.delete("printedName")
      card.delete("faceFlavorName")
      card.delete("flavorName")
    end
  end
end

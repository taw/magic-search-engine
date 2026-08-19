# Every rename of a card happens here, and it happens first.
#
# The index is keyed by card name, so two different cards ending up under one
# name is not something a later patch can recover from. Doing all renames up
# front also means no other patch has to cope with a name changing under it.
#
# Only mtgjson's raw fields are available at this point - in particular there
# is no "set_code" yet, so match on the official "setCode" instead.

class PatchCardNames < Patch
  def call
    fix_alchemy_names
    split_multiface_names
    fix_unsearchable_names
    disambiguate_playtest_cards
    disambiguate_prepared_spells
    update_names_index
  end

  private

  # mtgjson "A-Akki Ronin" turns into "Akki Ronin (Alchemy)"
  def fix_alchemy_names
    each_printing do |card|
      next unless card.delete("isRebalanced")
      card["name"] = alchemy_name_fix(card["name"])
      card["faceName"] = alchemy_name_fix(card["faceName"])
      # A-Town is a joke card, the A- is part of the name
      card["alchemy"] = true unless card["name"] == "A-Town"
    end
  end

  def alchemy_name_fix(name)
    return unless name
    name.split(" // ").map{|s|
      # Not sure about A-Town joke card
      # When I see it printed, I might decide if it should be A- or (Alchemy)
      if s =~ /\AA-(.*)/ and s != "A-Town"
        "#{$1} (Alchemy)"
      else
        s
      end
    }.join(" // ")
  end

  # mtgjson names a multipart printing after the whole card ("x // y") and puts
  # the face name in a separate field. We index one entry per face instead.
  def split_multiface_names
    each_printing do |card|
      if card["faceName"] and card["name"].include?("//")
        card["names"] = card["name"].split(" // ")
        card["name"] = card.delete("faceName")
      end
    end
  end

  # Names containing characters nobody can type
  # at some point I might decide to drop this and develop a better solution
  def fix_unsearchable_names
    each_printing do |card|
      case card["name"]
      when "Ratonhnhaké꞉ton"
        card["name"] = "Ratonhnhakéton"
      when "Human—Time Lord Meta-Crisis"
        card["name"] = "Human-Time Lord Meta-Crisis"
      end
    end
  end

  # Playtest cards share names with real cards far too often.
  # mtgjson used to disambiguate some of these, then dropped the disambiguation.
  def disambiguate_playtest_cards
    cmb_names = %W[
      Bind
      Fire
      Liberate
      Pick\ Your\ Poison
      Red\ Herring
      Saw
      Smelt
      Start
    ].map{|n| [n, "#{n} (CMB1)"]}.to_h
    cmb_names.default_proc = proc{|_, name| name}

    each_printing do |card|
      case card["setCode"]
      when "CMB1", "CMB2"
        card["name"] = cmb_names[card["name"]]
        card["names"] = card["names"].map{|n| cmb_names[n]} if card["names"]
      when "UNK"
        # conflicts with MBC "Joven and Chandler"
        if card["number"] == "UR05"
          card["name"] = "Joven and Chandler (Playtest)"
        end
        # "Fast // Furious" conflicts with the 40K card of the same name
        # (both halves share a collector number until PatchMultipartCardNumbers)
        if card["name"] == "Fast" or card["name"] == "Furious"
          card["name"] = "#{card["name"]} (UNK)"
          card["names"] = ["Fast (UNK)", "Furious (UNK)"]
        end
      when "PUNK"
        case card["number"]
        # planes conflict with UNK "Artist Alley" and MID/DBL "No Way Out"
        when "PLA001", "PLA001a"
          card["name"] = "Artist Alley (Plane)"
        when "PLA031"
          card["name"] = "No Way Out (Playtest)"
        end
      when "TBTH"
        # conflicts with the AKH card
        if card["name"] == "Unquenchable Fury"
          card["name"] = "Unquenchable Fury (TBTH)"
        end
      end
    end
  end

  # Prepared spells share names with the standalone cards they were made from.
  # Only those that also exist as standalone cards need special handling.
  def disambiguate_prepared_spells
    prepared_spells = Set[]
    each_card do |name, printings|
      layouts = printings.map{|c| c["layout"]}.uniq
      if layouts.include?("prepare") and layouts.size > 1
        prepared_spells << name
      end
    end

    each_printing do |card|
      next unless card["layout"] == "prepare"
      if prepared_spells.include?(card["name"])
        card["name"] = "#{card["name"]} (Prepared)"
      end
      card["names"] = card["names"].map{|n| prepared_spells.include?(n) ? "#{n} (Prepared)" : n }
    end
  end
end

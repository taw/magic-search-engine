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
    split_multiface_names
    fix_unsearchable_names
    disambiguate_playtest_cards
    disambiguate_prepared_spells
    update_names_index
  end

  private

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
    ].map{|n| [n, "#{n} (Playtest)"]}.to_h
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
          card["name"] = "#{card["name"]} (Playtest)"
          card["names"] = ["Fast (Playtest)", "Furious (Playtest)"]
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

  # Prepared spells share names with the standalone cards they were made from,
  # and the same spell can be prepared by several different creatures.
  # A prepared face keeps its plain name unless it needs disambiguating:
  # * paired with more than one card - "(Prepared a)", "(Prepared b)", ...
  #   lettered in alphabetical order of the card it is paired with
  # * also exists as a standalone card - "(Prepared)"
  def disambiguate_prepared_spells
    also_standalone = Set[]
    each_card do |name, printings|
      layouts = printings.map{|c| c["layout"]}.uniq
      if layouts.include?("prepare") and layouts.size > 1
        also_standalone << name
      end
    end

    pairings = Hash.new{|h, k| h[k] = []}
    each_printing do |card|
      next unless card["layout"] == "prepare"
      front, back = card["names"]
      pairings[front] |= [back]
      pairings[back] |= [front]
    end
    pairings.each_value(&:sort!)

    each_printing do |card|
      next unless card["layout"] == "prepare"
      names = card["names"]
      renamed = names.each_with_index.map{|name, i|
        prepared_name(name, names[1 - i], pairings, also_standalone)
      }
      card["name"] = renamed[names.index(card["name"])]
      card["names"] = renamed
    end
  end

  def prepared_name(name, pair, pairings, also_standalone)
    pairs = pairings[name]
    if pairs.size > 1
      "#{name} (Prepared #{("a".."z").to_a.fetch(pairs.index(pair))})"
    elsif also_standalone.include?(name)
      "#{name} (Prepared)"
    else
      name
    end
  end
end

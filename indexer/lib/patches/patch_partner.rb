# This does three things:
# - marks partner cards as such (Commander)
# - finds partners for cards (Commander and Battlebond)
#
# These are some very delicate regexps
class PatchPartner < Patch
  def call
    each_printing do |card|
      text = card["text"] or next
      if text.include?("Partner (You can have two commanders") or text.include?("Partner (You can have two comanders if they both have partner.)")
        card["is_partner"] = true
      elsif text.include?("Legendary Partner (You can have two commanders") or text.include?("Legendary partner (You can have two commanders")
        card["is_partner"] = true
      elsif text =~ /\bPartner with ([^\n\(]*)/
        card["is_partner"] = true
        partner_name = $1.strip
        # partners[card] = partner_name
        card["partner"] = find_partner_card_for(card, partner_name)
      elsif text =~ /Partner\s*\z/
        # CMR, some have no remainder text
        card["is_partner"] = true
      elsif text =~ /\bpartner\b/i
        raise "Unknown partner text"
      end
    end
  end

  # This needs to be one they share booster with
  # For now it's 1-to-1, it's possible someday it will be more complex system
  def find_partner_card_for(card, partner_name)
    card_name = card["name"]
    set_code = card["set_code"]
    number = card["number"]
    potential_partners = @cards[partner_name].select{|c| c["set_code"] == set_code }
    return potential_partners[0]["number"] if potential_partners.size == 1

    special_pairs = {
      "bbd" => [
        ["1", "2"],
        ["255", "256"],
      ],
      "voc" => [
        ["19", "25"],
        ["57", "63"],
        ["8", "16"],
        ["46", "54"],
      ],
      "sld" => [
        ["379a", "380a"],
        ["379b", "380b"],
        ["379★a", "380★a"],
        ["379★b", "380★b"],
      ]
    }

    if special_pairs[set_code]
      partner_numbers = special_pairs[set_code].flat_map{|a,b| [[a,b],[b,a]]}.to_h
      # Will / Rowan have two versions
      # VOC has two versions of each partner card too
      if partner_numbers[number]
        found_partner = potential_partners.find{|c| c["number"] == partner_numbers[number] }
        if found_partner
          return found_partner["number"]
        else
          raise "Can't find partner by card number for #{card_name}"
        end
      end
    end

    warn "Can't link partners: #{card_name} [#{set_code}/#{number}] to #{partner_name}"
    nil
  end
end

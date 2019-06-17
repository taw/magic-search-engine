# This should probably be multiple patches
# Also this whole file will need full rewrite for v4 migration
class PatchFixCollectorNumbers < Patch
  def call
    each_set do |set|
      fix_numbers(set)
    end
  end

  private

  def fix_numbers(set)
    set_code = set["code"]
    set_name = set["name"]
    cards = cards_by_set[set_code]

    case set_code
    when "bfz", "ogw"
      # No idea if this is correct
      basic_land_cards = cards.select{|c| (c["supertypes"]||[]) .include?("Basic") }
      basic_land_cards = basic_land_cards.sort_by{|c| [c["number"], c["multiverseid"]]}
      basic_land_cards.each_slice(2) do |a,b|
        raise unless a["number"] == b["number"]
        b["number"] += "A"
      end
    when "ust"
      cards_with_variants = %W[3 12 41 49 54 67 82 98 103 113 145 147 165]
      variant_counter = {}
      cards.each do |card_data|
        number = card_data["number"]
        next unless cards_with_variants.include?(number)
        variant_counter[number] = variant_counter[number] ? variant_counter[number].next : "A"
        card_data["number"] = number + variant_counter[number]
      end
    when "me4"
      # Gatherer numbers use same number for 4 alt art variants of each Urza's land
      # add A B C D to them
      cards.group_by{|c| c["number"]}.each do |number, variants|
        next if variants.size == 1
        variants.sort_by{|c| c["multiverseid"]}.each_with_index do |card, i|
          card["number"] += "ABCD"[i]
        end
      end
    # These are somewhat silly orders
    when "s00", "rqs"
      cards
        .sort_by{|c| [c["name"], c["multiverseid"]] }
        .each_with_index{|c,i| c["number"] = "#{i+1}"}
    end
  end
end

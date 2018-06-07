# This should probably be multiple patches
class PatchFixCollectorNumbers < Patch
  def call
    patch_set do |set|
      fix_numbers(set)
    end
  end

  private

  def fix_numbers(set)
    set_code = set["code"]
    set_name = set["name"]
    cards = cards_by_set[set_code]

    case set_code
    when "van"
      cards.sort_by{|c| c["multiverseid"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
    when "pch", "arc", "pc2", "pca", "e01"
      cards.each do |card|
        unless (card["types"] & ["Plane", "Phenomenon", "Scheme"]).empty?
          card["number"] = (1000 + card["number"].to_i).to_s
        end
      end
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
    # FIXME: These are some seriously failful orders, should probably get fixed at some point
    when "rqs"
      # I have no idea how that happened
      cards.sort_by{|c| c["original_order"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
      cards.find{|c| c["name"] == "Zephyr Falcon"}["number"] = "1"
      cards.find{|c| c["name"] == "Alabaster Potion"}["number"] = "54"
      # binding.pry
    when "me4"
      cards.sort_by{|c| c["multiverseid"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
    when "st2k"
      cards.sort_by{|c| c["original_order"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
    end
  end
end

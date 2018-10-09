# Fix rarities of ITP/RQS from "special" to whatever they were in 4ed
# These are basically 4ed precons, except with updated copyright from 1995 to 1996
# so it's silly to treat them as some "special" printings

class PatchItpRqsRarity < Patch
  def call
    each_card do |name, printings|
      affected_printings = printings.select{|printing| printing["set_code"] == "rqs" or printing["set_code"] == "itp"}
      next if affected_printings.empty?
      rarity_4ed = printings.find{|printing| printing["set_code"] == "4ed"}["rarity"]
      affected_printings.each do |printing|
        printing["rarity"] = rarity_4ed
      end
    end
  end
end

# Meld card numbers https://github.com/mtgjson/mtgjson/issues/420
class PatchEmnCardNumbers < Patch
  def call
    each_printing do |card|
      next unless card["set_code"] == "emn"
      if card["name"] == "Chittering Host"
        card["number"] = "96b"
      elsif card["name"] == "Hanweir Battlements"
        card["number"] = "204a"
      end
    end
  end
end

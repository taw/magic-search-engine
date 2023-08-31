# Should spellbook link to just the front part or to both parts?
class PatchSpellbook < Patch
  def call
    in_spellbook = {}

    each_printing do |printing|
      name = printing["name"]
      spellbook = printing.dig("relatedCards", "spellbook")
      next unless spellbook
      spellbook = spellbook.flat_map{|n| n.split(" // ") }.sort
      printing["spellbook"] = spellbook
      spellbook.each do |other|
        in_spellbook[other] ||= Set[]
        in_spellbook[other] << name
      end
    end

    each_printing do |printing|
      name = printing["name"]
      next unless in_spellbook[name]
      printing["in_spellbook"] = in_spellbook[name].sort
    end
  end
end

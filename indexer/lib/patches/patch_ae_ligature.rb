class PatchAeLigature < Patch
  def call
    each_printing do |card|
      next unless card["flavor"]
      card["flavor"] = card["flavor"].gsub("Æ", "Ae").gsub("æ", "ae")
    end
  end
end

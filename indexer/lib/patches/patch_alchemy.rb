class PatchAlchemy < Patch
  def call
    has_alchemy = Set[]

    each_printing do |card|
      next unless card["alchemy"]
      has_alchemy << card["name"].sub(" (Alchemy)", "")
    end

    each_printing do |card|
      next unless has_alchemy.include?(card["name"])
      card["has_alchemy"] = true
    end

    each_printing do |card|
      next unless card["alchemy"]
      next unless card["text"] =~ /A-/
      card["text"] = card["text"].gsub("A-", "")
    end
  end
end

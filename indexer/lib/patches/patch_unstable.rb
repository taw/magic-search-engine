class PatchUnstable < Patch
  def call
    hard_variants.each do |name|
      @cards[name].dup.each do |card|
        variant = card["number"][/[a-z]/]
        rename_printing card, "#{name} (#{variant})"
      end
    end
  end

  def hard_variants
    [
      "Everythingamajig",
      "Garbage Elemental",
      "Ineffable Blessing",
      "Knight of the Kitchen Sink",
      "Sly Spy",
      "Very Cryptic Command",
    ]
  end

  def call_v4
    soft_variants = [
      "Amateur Auteur (b)",
      "Amateur Auteur (c)",
      "Amateur Auteur (d)",
      "Beast in Show (b)",
      "Beast in Show (c)",
      "Beast in Show (d)",
      "Extremely Slow Zombie (b)",
      "Extremely Slow Zombie (c)",
      "Extremely Slow Zombie (d)",
      "Novellamental (b)",
      "Novellamental (c)",
      "Novellamental (d)",
      "Secret Base (b)",
      "Secret Base (c)",
      "Secret Base (d)",
      "Secret Base (e)",
      "Target Minotaur (b)",
      "Target Minotaur (c)",
      "Target Minotaur (d)",
    ]

    # Append (a)
    hard_variants.each do |name|
      rename name, "#{name} (a)"
    end

    # Merge all variants
    soft_variants.each do |name|
      rename name, name.sub(/ \(.\)\z/, "")
    end
  end
end

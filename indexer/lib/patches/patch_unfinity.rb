class PatchUnfinity < Patch
  def call
    hard_variants.each do |name|
      @cards[name].dup.each do |card|
        variant = card["number"][/[a-z]/]
        rename_printing card, "#{name} (#{variant})"
      end
    end

    # UPLIST does not follow convention
    renames.each do |name, variants|
      @cards[name].dup.each do |card|
        variant = variants[[card["set_code"], card["number"]]]
        next unless variant
        rename_printing card, "#{name} (#{variant})"
      end
    end

  end

  def hard_variants
    [
      "Scavenger Hunt",
      "The Superlatorium",
      "Trivia Contest",
    ]
  end

  def renames
    {
      "Everythingamajig" => {
        ["ulst", "55"] => "a",
        ["ulst", "56"] => "f",
      },
      "Ineffable Blessing" => {
        ["ulst", "37"] => "c",
        ["ulst", "38"] => "a",
      },
    }
  end
end

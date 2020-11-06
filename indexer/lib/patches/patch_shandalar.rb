class PatchShandalar < Patch
  # This includes cards from:
  # * Alpha
  # * Beta
  # * Unlimited
  # * Revised
  # * Arabian Nights,
  # * Antiquities,
  # * Legends and
  # * The Dark,
  # * as well as the twelve cards from the Astral Set
  # * and five cards that came from Magic the Gathering Novels

  def shandalar_sets
    @shandalar_sets ||= [
      "lea",
      "leb",
      "2ed",
      "3ed",
      "arn",
      "atq",
      "leg",
      "drk",
      "past",
      "phpr",
      "pdrc",
    ]
  end

  def shandalar_cards_path
    Pathname(__dir__) + "../../../data/shandalar.txt"
  end

  def shandalar_cards
    @shandalar_cards ||= begin
      shandalar_cards_path
        .readlines
        .grep_v(/\A#/)
        .map(&:chomp)
        .to_set
    end
  end

  def call
    matched = Set[]

    each_printing do |card|
      next unless shandalar_cards.include?(card["name"])
      next unless shandalar_sets.include?(card["set_code"])
      card["shandalar"] = true
      matched << card["name"]
    end

    missed_cards = shandalar_cards - matched

    missed_cards.each do |name|
      warn "Shandalar card: #{name} not matched"
    end
  end
end

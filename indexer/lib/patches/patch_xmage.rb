# This is not exposed in syntax help as data quality is still questionable

class PatchXmage < Patch
  def xmage_cards_path
    Pathname(__dir__) + "../../../data/xmage_cards.txt"
  end

  def xmage_cards
    @xmage_cards ||= begin
      xmage_cards_path
        .readlines
        .map(&:chomp)
        .map{|line| line.split("\t",2)}
        .to_set
    end
  end

  def call
    matched = Set[]

    each_printing do |card|
      name = card["name"]
      set_code = card["set_code"]
      next unless xmage_cards.include?([set_code, name])
      card["xmage"] = true
      matched << [set_code, name]
    end

    # This list is unfortunately quite long, and contains a lot of different cards
    # there for different reasons
    missed_cards = xmage_cards - matched
  end
end

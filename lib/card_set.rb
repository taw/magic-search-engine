class CardSet
  attr_reader :set_name, :set_code, :block_name, :block_code, :border, :release_date
  def initialize(data, db)
    @set_name     = data["set_name"]
    @set_code     = data["set_code"]
    @block_name   = data["block_name"]
    @block_code   = data["block_code"] && data["block_code"].downcase
    @border       = data["border"]
    @release_date = data["release_date"]
    @db = db
  end

  include Comparable
  def <=>(other)
    set_code <=> other.set_code
  end

  # For both of these:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def match_block?(query)
    return false unless @block_code and @block_name
    if @db.blocks.include?(query)
      @block_code == query.downcase or normalize_text(@block_name) == query
    else
      normalize_name(@block_name).include?(normalize_name(query))
    end
  end

  def match_set?(query)
    query = normalize_text(query)
    if @db.sets[query]
      @set_code == query.downcase or normalize_text(@set_name) == query
    else
      normalize_name(@set_name).include?(normalize_name(query))
    end
  end

  private

  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end
end

class ConditionSetType < Condition
  TypeAliases = {
    "2hg" => "two-headed giant",
    "arc" => "archenemy",
    "cmd" => "commander",
    "cns" => "conspiracy",
    "dd" => "duel deck",
    "ex" => "expansion",
    "ftv" => "from the vault",
    "me" => "masters",
    "pc" => "planechase",
    "pds" => "premium deck",
    "rep" => "reprint",
    "st" => "starter",
    "std" => "standard",
  }

  def initialize(set_type)
    set_type = normalize_name(set_type).gsub("_", " ")
    @set_type = TypeAliases[set_type] || set_type
  end

  def search(db)
    merge_into_set matching_sets(db).map(&:printings)
  end

  def to_s
    "st:#{maybe_quote(@set_type)}"
  end

  private

  def matching_sets(db)
    type_list = get_type_list(@set_type)
    sets = Set[]
    db.sets.each do |set_code, set|
      # CM1 is a fixed set so include it for commander or fixed but not for deck
      if set.code == "cm1"
        if type_list.include?("fixed")
          sets << set
        elsif type_list.include?("commander") and !type_list.include?("deck")
          sets << set
        end
        next
      end

      # starter sets fall into several categories
      if (%w(cp1 cp2 cp3).include?(set.code) and type_list.include?("deck")) ||
        (%w(ptk por p02 s99).include?(set.code) and type_list.include?("booster")) ||
        (%w(s00 w16 itp).include?(set.code) and type_list.include?("fixed"))
        sets << set
      end

      # file tempest remastered with "masters" sets
      if set.code == "tpr"
        if type_list.include?("masters")
          sets << set
        else
          next
        end
      end

      if type_list.include?(set.type)
        sets << set
      end
    end
    sets
  end

  def get_type_list(set_type)
    case set_type
    when "multiplayer"
      ["archenemy", "commander", "conspiracy", "planechase", "vanguard", "multiplayer", "two-headed giant"]
    when "booster"
      ["expansion", "conspiracy", "reprint", "core", "masters", "un", "booster"]
    when "fixed"
      ["from the vault", "vanguard", "fixed"]
    when "deck"
      ["archenemy", "commander", "duel deck", "premium deck", "planechase", "box", "deck"]
    when "standard"
      ["core", "expansion"]
    else
      [set_type]
    end
  end
end

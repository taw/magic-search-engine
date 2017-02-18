class ConditionSetType < Condition
  def initialize(set_type)
    set_type = normalize_name(set_type)
    @set_type = deabbreviate(set_type)
  end

  # For sets and blocks:
  # "in" is code for "Invasion", don't substring match "Innistrad" etc.
  # "Mirrodin" is name for "Mirrodin", don't substring match "Scars of Mirrodin"
  def search(db)
    matching_sets(db).map(&:printings).inject(Set[], &:|)
  end

  def to_s
    "st:#{maybe_quote(@set_type)}"
  end

  private

  def matching_sets(db)
    type_list = get_type_list(@set_type)
    sets = Set[]
    db.sets.each do |set_code, set|
      # CMA is a fixed set so include it for commander or fixed but not for deck
      if set.code == "cma"
        if type_list.include?("fixed")
          sets << set
        elsif type_list.include?("commander") and !type_list.include?("deck")
          sets << set
        end
        next
      end

      # starter sets fall into several categories
      if (set.code == "clash" and type_list.include?("deck")) ||
        (%w(p3k po po2 st).include?(set.code) and type_list.include?("booster")) ||
        (%w(st2k w16 itp).include?(set.code) and type_list.include?("fixed"))
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

      if set.custom?
        if type_list.include("custom")
          sets << set
        end
      end

      if type_list.include?(set.type)
        sets << set
      end
    end
    sets
  end

  def deabbreviate(set_type)
    set_type = "expansion" if set_type == "ex"
    set_type = "from the vault" if set_type == "ftv"
    set_type = "archenemy" if set_type == "arc"
    set_type = "commander" if set_type == "cmd"
    set_type = "conspiracy" if set_type == "cns"
    set_type = "duel deck" if set_type == "dd"
    set_type = "reprint" if set_type == "rep"
    set_type = "masters" if set_type == "me"
    set_type = "starter" if set_type == "st"
    set_type = "premium deck" if set_type == "pds"
    set_type = "planechase" if set_type == "pc"
    set_type
  end

  def get_type_list(set_type)
    type_list = [set_type]
    if set_type == "multi" then type_list = %W(archenemy commander conspiracy planechase vanguard multi)
    elsif set_type == "booster" then type_list = %W(expansion conspiracy reprint core masters un booster)
    elsif set_type == "fixed" then type_list = %W(from\ the\ vault vanguard fixed)
    elsif set_type == "deck" then type_list = %W(archenemy commander duel\ deck premium\ deck planechase box deck)
    end
    type_list
  end
end

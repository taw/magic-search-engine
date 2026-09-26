class ConditionFaces < Condition
  # "a // b // c" - a card with at least that many faces, where each condition
  # matches a different face. nil stands for an empty side, which any face
  # satisfies, so "a //" is a multipart card with a face matching a.
  def initialize(*conds)
    @conds = conds
  end

  def search_all(db)
    face_count = @conds.size
    multipart = db.printings.select(&:others)
    sets = @conds.compact.map{|cond| cond.search(db, multipart).to_set }.sort_by(&:size)
    # Any matching card has a face in the smallest set. `others` is symmetric
    # but not transitive - a meld result lists both fronts, each front lists
    # only the result - so check every face's own view of the card.
    if sets.empty?
      pivots = multipart
    else
      pivots = sets[0].flat_map{|c| [c, *c.others] }.uniq
    end
    result = []
    pivots.each do |c|
      faces = [c, *c.others]
      next if faces.size < face_count
      # Empty sides need no assignment: any faces left over satisfy them
      result.concat(faces) if assign_faces?(faces, sets)
    end
    result.uniq
  end

  def metadata!(key, value)
    super
    @conds.each{|cond| cond&.metadata!(key, value)}
  end

  def to_s
    "(#{@conds.map{|cond| cond ? " #{cond} " : " "}.join("//").strip})"
  end

  def explain(negated: false)
    conds = @conds.compact
    if conds.empty?
      explanation = "the card has at least #{@conds.size} parts"
    else
      parts = conds.map.with_index{|cond, i|
        "#{i == 0 ? "a part" : "another part"} where #{cond.compound? ? "(#{cond.explain})" : cond.explain}"
      }
      parts += ["another part"] * (@conds.size - conds.size)
      explanation = "the card has #{parts.join(", and ")}"
    end
    negated ? "not (#{explanation})" : explanation
  end

  private

  # Is there a way to give each set its own distinct face? Cards have at most
  # a handful of faces, so plain backtracking is fine.
  def assign_faces?(faces, sets, used=[])
    return true if used.size == sets.size
    set = sets[used.size]
    faces.any? do |face|
      !used.include?(face) and set.include?(face) and assign_faces?(faces, sets, [*used, face])
    end
  end
end

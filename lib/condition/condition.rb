class Condition
  def include_extras?
    false
  end

  def inspect
    to_s
  end

  def search(db)
    # Set#select should return damn set, it's dumb that it returns Array
    Set.new(db.printings.select{|card| match?(card)})
  end

  private

  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
  end

  def maybe_quote(text)
    if text =~ /\A[a-zA-Z0-9]+\z/
      text
    else
      text.inspect
    end
  end
end

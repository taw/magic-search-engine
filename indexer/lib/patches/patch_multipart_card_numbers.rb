class PatchMultipartCardNumbers < Patch
  def call
    each_set do |set|
      fix_numbers(set)
    end
  end

  private

  def fix_numbers(set)
    set_code = set["code"]
    cards = cards_by_set[set_code]
    numbers = cards.map{|c| c["number"]}
    duplicates = cards
      .group_by{|c| c["number"]}
      .select{|_,cs| cs.size > 1}
    return if duplicates.empty?
    duplicates.each do |number, cards|
      actual_names = cards.map{|c| c["name"]}
      next if actual_names.size != actual_names.uniq.size
      # If it's a multipart card, append a, b, etc.
      all_names = cards.map{|c| c["names"] }
      next unless all_names.uniq.size == 1 and all_names.uniq[0] != nil
      names_order = all_names[0]
      next unless actual_names.sort == names_order.sort
      alphabet = [*"a".."z"]
      cards.each do |c|
        c["number"] += alphabet.fetch(names_order.index(c["name"]))
      end
    end
  end
end

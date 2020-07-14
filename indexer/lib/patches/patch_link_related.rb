class PatchLinkRelated < Patch
  def call
    # The index has tokens as cards, CardDatabase filters them out
    # We should probably move them out of the way before that
    all_card_names = @cards.values.flatten.select{|c| c["layout"] != "token"}.map{|c| c["name"]}.uniq

    # Get longest match so
    # "Take Inventory" doesn't mistakenly seem to refer to "Take" etc.
    # Second regexp for empire series
    any_card = Regexp.union(all_card_names.sort_by(&:size).reverse)
    rx = /\b(?:named|Partner with|token copy of) (#{any_card})(?:(?:,|,? and|,? or) (#{any_card}))?(?:(?:,|,? and|,? or) (#{any_card}))?/

    # Extract links
    links = {}
    each_printing do |printing|
      name = printing["name"]
      matching_cards = (printing["text"]||"").scan(rx).flatten.uniq - [name, nil]
      next if matching_cards.empty?
      matching_cards.each do |other|
        links[name] ||= Set[]
        links[name] << other
        links[other] ||= Set[]
        links[other] << name
      end
    end

    # Apply links
    links.each do |name, others|
      @cards[name].each do |printing|
        printing["related"] = others.sort
      end
    end
  end
end

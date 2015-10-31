module ApplicationHelper
  def link_to_card(card, &blk)
    link_to(controller: "card", action: "show", set: card.set_code, id: card.number, &blk)
  end

  def link_to_set(set, &blk)
    link_to(controller: "set", action: "show", id: set.set_code, &blk)
  end

  def link_to_search(search, &blk)
    link_to(controller: "card", action: "index", q: search, &blk)
  end
end

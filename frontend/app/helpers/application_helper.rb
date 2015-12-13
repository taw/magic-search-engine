module ApplicationHelper
  def link_to_card(card, &blk)
    link_to(controller: "card", action: "show", set: card.set_code, id: card.number, &blk)
  end

  def link_to_set(set, &blk)
    link_to(controller: "set", action: "show", id: set.code, &blk)
  end

  def link_to_search(search, &blk)
    link_to(controller: "card", action: "index", q: search, &blk)
  end

  def format_oracle_text(card_text)
    h(card_text).gsub("\n", "<br/>").gsub(/\{(.*?)\}/) do
      sym  = $&
      mana = $1.gsub("/", "").downcase
      if good_mana_symbols.include?(mana)
        %Q[<span class="mana mana-#{mana}">#{sym}</span>]
      else
        sym
      end
    end.html_safe
  end

  def good_mana_symbols
    @good_mana_symbols ||= Set["x", "y", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "15", "16", "20", "w", "u", "b", "r", "g", "wu", "wb", "rw", "gw", "ub", "ur", "gu", "br", "bg", "rg", "2w", "2u", "2b", "2r", "2g", "s", "q", "t", "wp", "up", "bp", "rp", "gp"]
  end

  def card_picture_path(card)
    return nil unless card.multiverseid
    url = "/cards/#{card.set_code}/#{card.number}.png"
    file_path = Pathname(__dir__) + "../../public#{url}"
    if file_path.exist?
      url
    else
      nil
    end
  end
end

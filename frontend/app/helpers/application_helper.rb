module ApplicationHelper
  def link_to_card(card, &blk)
    link_to(
      controller: "card",
      action: "show",
      set: card.set_code,
      id: card.number,
      name: card.name_slug,
      &blk)
  end

  def url_for_card(card)
    url_for(
      controller: "card",
      action: "show",
      set: card.set_code,
      id: card.number,
      name: card.name_slug,
    )
  end

  def link_to_card_name(card_name, &blk)
    link_to(
      controller: "card",
      action: "index",
      q: "!#{card_name}",
      &blk)
  end

  def link_to_set(set, &blk)
    link_to(controller: "set", action: "show", id: set.code, &blk)
  end

  def link_to_pack(pack, &blk)
    link_to(controller: "pack", action: "show", id: pack.code, &blk)
  end

  def link_to_deck(deck, &blk)
    link_to(controller: "deck", action: "show", set: deck.set_code, id: deck.slug, &blk)
  end

  def download_link_to_deck(deck, *html_options, &blk)
    link_to({controller: "deck", action: "download", set: deck.set_code, id: deck.slug}, *html_options, &blk)
  end

  def link_to_artist(artist, &blk)
    link_to(controller: "artist", action: "show", id: artist.slug, &blk)
  end

  def link_to_search(search, &blk)
    link_to(controller: "card", action: "index", q: search, &blk)
  end

  def link_to_subset(set_code, subset, &blk)
    query = %Q[e:#{set_code} subset:"#{subset}"]
    link_to(
      controller: "card",
      action: "index",
      q: query,
      &blk)
  end

  def format_mana_symbols_in_text(text)
    text
      .gsub(/(?:\{.*?\})+/) do
        %[<span class="manacost">] + format_mana_symbols($&) + %[</span>]
      end
      .gsub(/\[([\+\-\u2013\u2212]?(?:\d+|N|X))\]/i) do
        replace_planeswalker_symbol($1)
      end
  end

  def format_oracle_text(card_text)
    h(card_text || "")
      .gsub(/\A\n+/, "")
      .gsub("&#39;", "'") # regex doesn't work if we escape here, and later we have legit html in the output already
      .gsub(Card::ABILITY_WORD_RX) do |m|
        "<i class='ability_word'>#{$1}</i> —"
      end
      .gsub("\n", "<br/>")
      .gsub(/(?:\{.*?\})+/) do
        %[<span class="manacost">] + format_mana_symbols($&) + %[</span>]
      end
      .gsub(/\[([\+\-\u2013\u2212]?(?:\d+|N|X))\]/i) do
        replace_planeswalker_symbol($1)
      end
      .gsub(/
        \(
          (?: [^\(\)] | \( [^\(\)]* \) )*
        \)/x) do
        # Urza has nested parentheses
        %[<i class="reminder-text">#{$&}</i>]
      end
      .html_safe
  end

  def replace_planeswalker_symbol(symbol)
    symbol = symbol.upcase
    csymbol = symbol.downcase.sub(/[-\+\u2212]/, "")
    usymbol = symbol.sub("-", "\u2013").sub("\u2212", "\u2013")
    if usymbol[0] == "+"
      dir = "up"
    elsif usymbol[0] == "\u2013"
      dir = "down"
    else
      dir = "zero"
    end
    %[<i class="mana mana-loyalty mana-loyalty-#{dir} mana-loyalty-#{csymbol}"></i>] +
    %[<span class="sr-only">[#{usymbol}]</span>]
  end

  def card_picture_path(card)
    ApplicationHelper.card_picture_path(card)
  end

  def card_picture_path_hq(card)
    ApplicationHelper.card_picture_path_hq(card)
  end

  def card_picture_path_lq(card)
    ApplicationHelper.card_picture_path_lq(card)
  end

  def card_gallery_path(card)
    first_printing = card.printings.first
    "/card/gallery/#{first_printing.set_code}/#{first_printing.number}"
  end

  def printings_view(selected_printing, matching_printings)
    matching_printings = matching_printings.to_set
    selected_printing
      .printings
      .sort_by{|cp| [cp.release_date, cp]}
      .map{|cp|
        if cp == selected_printing
          [:selected, cp]
        elsif matching_printings.include?(cp)
          [:matching, cp]
        else
          [:not_matching, cp]
        end
      }
      .group_by{|type, cp| cp.set_name }
      .to_a
      .reverse
  end

  def printings_view_full(selected_printing, matching_printings)
    matching_printings = matching_printings.to_set
    selected_printing
      .printings
      .sort_by{|cp| [cp.release_date, cp]}
      .map{|cp|
        if cp == selected_printing
          [:selected, cp]
        elsif matching_printings.include?(cp)
          [:matching, cp]
        else
          [:not_matching, cp]
        end
      }
      .group_by{|type, cp| [cp.set_name, cp.rarity] }
      .to_a
      .reverse
  end

  def self.card_picture_path(card)
    url_hq = "/cards_hq/#{card.set_code}/#{card.number}.png"
    url_lq = "/cards/#{card.set_code}/#{card.number}.png"
    path_hq = Pathname(__dir__) + "../../public#{url_hq}"
    path_lq = Pathname(__dir__) + "../../public#{url_lq}"
    return url_hq if path_hq.exist?
    return url_lq if path_lq.exist?
    nil
  end

  def self.card_picture_path_hq(card)
    url_hq = "/cards_hq/#{card.set_code}/#{card.number}.png"
    path_hq = Pathname(__dir__) + "../../public#{url_hq}"
    return url_hq if path_hq.exist?
    nil
  end

  def self.card_picture_path_lq(card)
    url_lq = "/cards/#{card.set_code}/#{card.number}.png"
    path_lq = Pathname(__dir__) + "../../public#{url_lq}"
    return url_lq if path_lq.exist?
    nil
  end

  private

  def format_mana_symbols(syms)
    syms.gsub(/\{(.*?)\}/) do
      sym = $&.upcase
      mana = $1.delete("/").downcase
      if good_mana_symbols.include?(mana)
        if mana[0] == "h"
          %[<span class="mana mana-half"><span class="mana mana-cost mana-#{mana[1..-1]}"><span class="sr-only">#{sym}</span></span></span>]
        elsif mana == "p" or mana == "chaos" or mana == "pw" or mana == "e"
          %[<span class="mana mana-#{mana}"><span class="sr-only">#{sym}</span></span>]
        else
          %[<span class="mana mana-cost mana-#{mana}"><span class="sr-only">#{sym}</span></span>]
        end
      else
        sym
      end
    end.html_safe
  end

  def good_mana_symbols
    @good_mana_symbols ||= Set[
      "x", "y", "z",
      "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
      "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
      "w", "u", "b", "r", "g",
      "wu", "wb", "rw", "gw", "ub", "ur", "gu", "br", "bg", "rg",
      "2w", "2u", "2b", "2r", "2g",
      "wp", "up", "bp", "rp", "gp", "p",
      "s", "q", "t", "c", "e",
      "½", "1000000", "100", "∞",
      "chaos", "pw",
      "hw", "hr",
      "wup", "wbp", "rwp", "gwp", "ubp", "urp", "gup", "brp", "bgp", "rgp",
      "tk",
    ]
  end

  def language_name(language_code)
    {
      cs: "Simplified Chinese",
      ct: "Traditional Chinese",
      fr: "French",
      de: "German",
      it: "Italian",
      jp: "Japanese",
      kr: "Korean",
      pt: "Brazilian Portuguese",
      ru: "Russian",
      sp: "Spanish",
    }.fetch(language_code)
  end

  # We should probably just use this everywhere
  def official_language_code(language_code)
    {
      cs: "zh-CN",
      ct: "zh-TW",
      sp: "es",
      jp: "ja",
    }[language_code] || language_code
  end

  def language_flag(language_code)
    {
      cs: "cn",
      ct: "tw",
      fr: "fr",
      de: "de",
      it: "it",
      jp: "jp",
      kr: "kr",
      pt: "br",
      ru: "ru",
      sp: "es",
    }.fetch(language_code)
  end

  def preview_id(card)
    [card.set_code, card.number, card.foil ? "foil" : nil].compact.join("-")
  end
end

module ApplicationHelper
  # url_for(controller:, action:, ...) runs Rails' full route generation on every
  # call, which is about 10x the cost of interpolating the path ourselves. Search
  # results, the deck index and the artist index each render thousands of links,
  # and the footer renders eleven of them on every single page, so we build the
  # paths by hand. Segments go through escape_segment so ★ in collector numbers
  # and friends come out identical to what url_for produced.
  URL_UTILS = ActionDispatch::Journey::Router::Utils

  def url_segment(value)
    URL_UTILS.escape_segment(value.to_s)
  end

  # url_for drops nil params, Hash#to_query renders them as "key=", so compact first
  def url_query(params)
    params.compact.to_query
  end

  def card_url(card)
    "/card/#{url_segment card.set_code}/#{url_segment card.number}/#{url_segment card.name_slug}"
  end
  alias_method :url_for_card, :card_url

  def card_gallery_url(card)
    "/card/gallery/#{url_segment card.set_code}/#{url_segment card.number}"
  end

  def card_availability_url(card)
    "/card/availability/#{url_segment card.set_code}/#{url_segment card.number}"
  end

  def search_url(query)
    "/card?#{url_query(q: query)}"
  end

  def card_name_url(card_name)
    search_url("!#{card_name}")
  end

  def subset_url(set_code, subset)
    search_url(%Q[e:#{set_code} subset:"#{subset}"])
  end

  def set_url(set)
    "/set/#{url_segment set.code}"
  end

  def pack_url(pack)
    "/pack/#{url_segment pack.code}"
  end

  def artist_url(artist)
    "/artist/#{url_segment artist.slug}"
  end

  def product_url(product)
    "/product/#{url_segment product.set_code}/#{url_segment product.slug}"
  end

  def deck_url(deck)
    "/deck/#{url_segment deck.set_code}/#{url_segment deck.slug}"
  end

  def deck_download_url(deck)
    "#{deck_url(deck)}/download"
  end

  def deck_download_with_printings_url(deck)
    "#{deck_url(deck)}/download_with_printings"
  end

  def limited_format_url(limited_format)
    "/limited_format/#{url_segment limited_format.set_code}/#{url_segment limited_format.slug}"
  end

  def format_url(format_name)
    "/format/#{url_segment format_name.parameterize}"
  end

  def link_to_card(card, &blk)
    link_to(card_url(card), &blk)
  end

  def link_to_query(query, &blk)
    link_to(search_url(query), &blk)
  end

  def link_to_card_name(card_name, &blk)
    link_to(card_name_url(card_name), &blk)
  end

  def link_to_set(set, &blk)
    link_to(set_url(set), &blk)
  end

  def link_to_pack(pack, &blk)
    link_to(pack_url(pack), &blk)
  end

  def link_to_limited_format(limited_format, &blk)
    link_to(limited_format_url(limited_format), &blk)
  end

  # Not every limited format has a page yet
  def limited_format_page?(limited_format)
    LimitedFormatController.supported_type?(limited_format.type)
  end

  # "A (A-CODE), B (B-CODE), or C (C-CODE)" - what one pack picked at random
  # out of a list could have been
  def pack_alternatives(packs)
    packs.map{|pack|
      safe_join([link_to_pack(pack){pack.name}, " (#{pack.code.upcase})"])
    }.to_sentence(two_words_connector: " or ", last_word_connector: ", or ").html_safe
  end

  # Sealed simulator opens the packs of the pool, and hands out the promo cards
  # for free. It has no notion of promos not being part of deck construction.
  # A pack picked at random is passed as its alternatives joined by "|", and
  # the simulator rolls it.
  def link_to_sealed_simulator(pool, &blk)
    link_to(sealed_simulator_url(pool), &blk)
  end

  def sealed_simulator_url(pool)
    boosters =
      pool.boosters.map{|count, pack| [count, pack.code]} +
      pool.random_boosters.map{|random| [random.pick, random.packs.map(&:code).join("|")]}
    "/sealed?" + url_query(
      count: boosters.map{|count, code| count},
      set: boosters.map{|count, code| code},
      fixed: pool.promo_cards.map{|card| FixedCardList.line_for(card)}.join("\n").presence,
    )
  end

  def link_to_product(product, &blk)
    link_to(product_url(product), &blk)
  end

  def link_to_deck(deck, &blk)
    link_to(deck_url(deck), &blk)
  end

  # An availability list mixes three unrelated classes with three unrelated
  # pages, and there is no common base class to hang this off
  def link_to_availability(entry, &blk)
    if entry.deck?
      link_to_deck(entry.source, &blk)
    elsif entry.booster?
      link_to_pack(entry.source, &blk)
    else
      link_to_product(entry.source, &blk)
    end
  end

  # Booster and product names already say which set they belong to
  # ("Zendikar Rising Set Booster", "Bloomburrow Bundle"); deck names do not.
  def availability_name(entry)
    if entry.deck?
      "#{entry.source.name} (#{entry.source.set_name} #{entry.source.type})"
    else
      entry.source.name
    end
  end

  # On a page already grouped by set, a deck from that set only needs its type:
  # "Death Toll (Commander Deck)", not "Death Toll (Duskmourn: House of Horror
  # Commander Commander Deck)". A deck from another set still has to say so -
  # The List's printings are given out by other sets' decks and boosters.
  def availability_name_in_set(entry, set)
    if entry.deck? and entry.source.set.equal?(set)
      "#{entry.source.name} (#{entry.source.type})"
    else
      availability_name(entry)
    end
  end

  def download_link_to_deck(deck, *html_options, &blk)
    link_to(deck_download_url(deck), *html_options, &blk)
  end

  def download_with_printings_link_to_deck(deck, *html_options, &blk)
    link_to(deck_download_with_printings_url(deck), *html_options, &blk)
  end

  def link_to_artist(artist, &blk)
    link_to(artist_url(artist), &blk)
  end

  def link_to_search(search, &blk)
    link_to(search_url(search), &blk)
  end

  def link_to_subset(set_code, subset, &blk)
    link_to(subset_url(set_code, subset), &blk)
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

  # Saga chapter abilities are lines like "I — ...", "I, II — ...".
  # Must run while the text still has newlines, as ^ anchors to them.
  SAGA_CHAPTERS = {"I" => 1, "II" => 2, "III" => 3, "IV" => 4, "V" => 5, "VI" => 6}
  SAGA_CHAPTER_RX = /^(#{Regexp.union(SAGA_CHAPTERS.keys)}(?:, #{Regexp.union(SAGA_CHAPTERS.keys)})*) — /

  def replace_saga_chapter_symbols(chapters)
    chapters.split(", ").map{|chapter|
      %[<i class="mana mana-saga mana-saga-#{SAGA_CHAPTERS[chapter]}"></i>]
    }.join +
    %[<span class="sr-only">#{chapters}</span> — ]
  end

  def format_oracle_text(card_text)
    h(card_text || "")
      .gsub(/\A\n+/, "")
      .gsub("&#39;", "'") # regex doesn't work if we escape here, and later we have legit html in the output already
      .gsub(AbilityWord::ABILITY_WORD_RX) do |m|
        "<i class='ability_word'>#{$1}</i> —"
      end
      .gsub(SAGA_CHAPTER_RX) do
        replace_saga_chapter_symbols($1)
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
    # Pick Your Poison (CMB1), there are no icons for that
    # and paper card literally has "[1]" etc. in it
    return "[#{symbol}]" if symbol =~ /\A[1-9]+\z/
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

  # Helpers specifically for HQ and LQ image sets are only used by verify_scans page
  def card_picture_path_hq(card)
    url_hq = "/cards_hq/#{card.set_code}/#{card.number}.png"
    path_hq = Pathname(__dir__) + "../../public#{url_hq}"
    return url_hq if path_hq.exist?
    nil
  end

  def card_picture_path_lq(card)
    url_lq = "/cards/#{card.set_code}/#{card.number}.png"
    path_lq = Pathname(__dir__) + "../../public#{url_lq}"
    return url_lq if path_lq.exist?
    nil
  end

  def card_gallery_path(card)
    card_gallery_url(card.default_printing)
  end

  def card_availability_path(card)
    card_availability_url(card.default_printing)
  end

  # A set's worth of per-printing availability, turned inside out: one row per
  # (source, finishes), naming every printing that source gives in those
  # finishes. A booster whose foil sheet holds printings its nonfoil sheet does
  # not is two rows, and a printing nothing reaches lands in the last row.
  #
  #   Strixhaven Draft Booster - 100 101 102 (foil)
  #   Strixhaven Draft Booster - 103 104 (nonfoil and foil)
  #   Strixhaven Collector Booster - 100 101 102 103 104 (nonfoil and foil)
  #
  # Rows keep the order availability itself is in - decks, then boosters, then
  # products - with a source's own rows kept together.
  def availability_view(printings, availability)
    rows = {}
    source_order = {}.compare_by_identity
    unavailable = []
    # Collector number order, since the numbers are what the rows are made of.
    # It decides row order too - a source is first named by the lowest numbered
    # printing it gives.
    printings.sort_by(&:number_sort_index).each do |printing|
      entries = availability[printing]
      unavailable << printing if entries.empty?
      entries.each do |entry|
        source_order[entry.source] ||= source_order.size
        # CardAvailability has no hash/eql?, and two entries for one source are
        # only the same row if they are the same finishes
        row = (rows[[entry.source.object_id, entry.finishes]] ||= [entry, []])
        row[1] << printing
      end
    end
    rows = rows.values.sort_by.with_index{|(entry, _), i| [source_order[entry.source], i]}
    rows << [nil, unavailable] unless unavailable.empty?
    rows
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
      .sort_by{|cp| [cp.release_date_i, cp.default_sort_index]}
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
    }[language_code] || language_code.to_s
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

  def format_display(text)
    text.gsub(/(\[(.*?):(.*?)\])/) { link_to_query("e:#{$2} number:#{$3} ++") { $1 } }.gsub("\n", "<br/>").html_safe
  end

  private

  def format_mana_symbols(syms)
    syms.gsub(/\{(.*?)\}/) do
      sym = $&.upcase
      mana = $1.delete("/").downcase
      if good_mana_symbols.include?(mana)
        if mana == "p" or mana == "chaos" or mana == "pw" or mana == "e" or mana == "h"
          # No circle
          %[<span class="mana mana-#{mana}"><span class="sr-only">#{sym}</span></span>]
        elsif mana[0] == "h"
          %[<span class="mana mana-half"><span class="mana mana-cost mana-#{mana[1..-1]}"><span class="sr-only">#{sym}</span></span></span>]
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
      "wp", "up", "bp", "rp", "gp",
      "cw", "cu", "cb", "cr", "cg",
      "h",
      "p",
      "s", "q", "t", "c", "e",
      "½", "1000000", "100", "∞",
      "chaos", "pw",
      "hw", "hr",
      "wup", "wbp", "rwp", "gwp", "ubp", "urp", "gup", "brp", "bgp", "rgp",
      "tk", "a",
      "l", "d",
    ]
  end
end

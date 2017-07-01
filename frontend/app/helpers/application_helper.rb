module ApplicationHelper
  def link_to_card(card, &blk)
    link_to(
      controller: "card",
      action: "show",
      set: card.set_code,
      id: card.number,
      # This part is purely decorative, so we don't bother desting it
      name: card.name
                .gsub("'s", "s")
                .gsub("I'm", "Im")
                .gsub("You're", "youre")
                .gsub("R&D", "RnD")
                .gsub(/[^a-zA-Z0-9\-]+/, "-")
                .gsub(/(\A-)|(-\z)/, ""),
      &blk)
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

  def link_to_artist(artist, &blk)
    link_to(controller: "artist", action: "show", id: artist.slug, &blk)
  end

  def link_to_search(search, &blk)
    link_to(controller: "card", action: "index", q: search, &blk)
  end

  def format_oracle_text(card_text)
    h(card_text).gsub("\n", "<br/>").gsub(/(?:\{.*?\})+/) do
      %Q[<span class="manacost">] + format_mana_symbols($&) + %Q[</span>]
    end.html_safe
  end

  def card_picture_path(card)
    ApplicationHelper.card_picture_path(card)
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

  def set_names_and_codes
    $CardDatabase
      .sets
      .values
      .sort_by{|s| [-s.release_date.to_i_sort, s.name] }
      .map{|set| [set.name, set.code]}
  end

  def block_names_codes_and_sets
    blocks = {}
    $CardDatabase
      .sets
      .values
      .select(&:block_name)
      .sort_by{|s| [-s.release_date.to_i_sort, s.name] }
      .each do |set|
      key = [set.block_name, set.block_code]
      (blocks[key] ||= []) << set.name
    end
    blocks.map{|(name, code), sets| [name, code, sets.reverse.join(", ")] }
  end

  def watermarks
    $CardDatabase
      .printings
      .sort_by(&:release_date)
      .map(&:watermark)
      .uniq
      .compact
  end

  private

  def format_mana_symbols(syms)
    syms.gsub(/\{(.*?)\}/) do
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
    @good_mana_symbols ||= Set["x", "y", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "w", "u", "b", "r", "g", "wu", "wb", "rw", "gw", "ub", "ur", "gu", "br", "bg", "rg", "2w", "2u", "2b", "2r", "2g", "s", "q", "t", "wp", "up", "bp", "rp", "gp", "c", "e"]
  end

  def language_name(language_code)
    {
      "cs" => "Simplified Chinese",
      "ct" => "Traditional Chinese",
      "fr" => "French",
      "de" => "German",
      "it" => "Italian",
      "jp" => "Japanese",
      "kr" => "Korean",
      "pt" => "Brazilian Portuguese",
      "ru" => "Russian",
      "sp" => "Spanish",
    }.fetch(language_code)
  end

  def language_flag(language_code)
    {
      "cs" => "cn",
      "ct" => "tw",
      "fr" => "fr",
      "de" => "de",
      "it" => "it",
      "jp" => "jp",
      "kr" => "kr",
      "pt" => "br",
      "ru" => "ru",
      "sp" => "es",
    }.fetch(language_code)
  end
end

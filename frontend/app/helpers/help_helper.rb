module HelpHelper
  def search_help(query, explanation)
    "<li>#{format_mana_symbols_in_text explanation} - #{link_to_search(query){ query }}</li>".html_safe
  end
end

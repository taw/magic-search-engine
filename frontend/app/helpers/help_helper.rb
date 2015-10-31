module HelpHelper
  def search_help(query, explanation)
    "<li>#{explanation} - #{link_to_search(query){ query }}</li>".html_safe
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # isn't there a standard way to do this already?
  def render_404
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end

  def render_403
    render file: "#{Rails.root}/public/403.html", layout: false, status: 403
  end

  private

  def paginate_by_set(printings, page)
    printings
             .sort_by{|c| [-c.release_date_i, c.set_name, c.name]}
             .group_by(&:set)
             .to_a
             .paginate(page: page, per_page: 10)
  end
end

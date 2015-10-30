class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # isn't there a standard way to do this already?
  def render_404
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end
end

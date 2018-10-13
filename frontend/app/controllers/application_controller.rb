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

  protected

  def current_user
    @current_user ||= User.find_by!(uid: session[:user_id])
  end

  def signed_in?
    !!current_user
  end

  helper_method :current_user, :signed_in?

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.uid
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

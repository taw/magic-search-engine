require_relative 'boot'

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Frontend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_view.logger = nil

    # Lore Seeker extension: need cookies for auth
    config.session_store :cookie_store
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
    config.middleware.delete ActionDispatch::Flash
  end
end

# will_paginate hacks
# based on https://stackoverflow.com/questions/4592489/adding-rel-nofollow-to-will-paginate-links-in-rails/12075691
require "will_paginate/view_helpers/action_view"
class LinkRendererRelNofollow < WillPaginate::ActionView::LinkRenderer
  def rel_value(page)
    case page
    when @collection.previous_page
      "prev nofollow" + (page == 1 ? " start nofollow" : "")
    when @collection.next_page
      "next nofollow"
    when 1
      "start nofollow"
    else
      "nofollow"
    end
  end
end

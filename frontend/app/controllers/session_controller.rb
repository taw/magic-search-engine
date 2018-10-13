class SessionController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    @user = User.find_or_create_from_hash(auth_hash)
    self.current_user = @user
    redirect_to request.env['omniauth.origin'] || '/'
  end
end

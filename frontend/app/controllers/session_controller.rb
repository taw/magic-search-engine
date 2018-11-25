class SessionController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    @user = User.find_or_create_from_hash(auth_hash)
    self.current_user = @user
    redirect_to request.env['omniauth.origin'] || '/'
  end

  def destroy
    self.current_user = nil
    redirect_to '/' #TODO redirect back to original page?
  end
end

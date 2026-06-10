class Dev::SessionsController < ApplicationController
  def create
    user = User.find(1)
    session[:userinfo] = {
      'sub' => "dev|#{user.id}",
      'name' => [user.first_name, user.last_name].compact.join(' ')
    }

    redirect_to root_path, notice: 'Logged in as dev user.'
  end
end

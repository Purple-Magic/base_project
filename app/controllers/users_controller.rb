class UsersController < ApplicationController
  include Secured

  def show
    @user = current_user_profile
  end
end

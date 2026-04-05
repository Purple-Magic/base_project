module Secured
  extend ActiveSupport::Concern

  included do
    before_action :require_auth0_login
  end

  private

  def require_auth0_login
    return if logged_in_using_omniauth?

    redirect_to root_path, alert: "Please log in to continue."
  end
end

class Auth0Controller < ApplicationController
  def callback
    auth_info = request.env["omniauth.auth"]
    session[:userinfo] = auth_info.dig("extra", "raw_info") || {}

    redirect_to user_path, notice: "You have been logged in successfully."
  end

  def failure
    @error_msg = params[:message].presence || "Authentication failed."

    render :failure, status: :unauthorized
  end

  def logout
    reset_session

    redirect_to logout_url, allow_other_host: true
  end

  private

  def logout_url
    request_params = {
      returnTo: root_url,
      client_id: auth0_client_id
    }

    URI::HTTPS.build(
      host: auth0_domain,
      path: "/v2/logout",
      query: request_params.to_query
    ).to_s
  end

  def auth0_client_id
    Rails.configuration.x.auth0.client_id
  end

  def auth0_domain
    Rails.configuration.x.auth0.domain
  end
end

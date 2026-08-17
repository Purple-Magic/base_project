class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :auth0_configured?, :current_user_name, :current_user_profile, :logged_in_using_omniauth?, :tailwind_stylesheet_available?

  private

  def current_user_profile
    return unless session[:userinfo].is_a?(Hash)

    session[:userinfo].with_indifferent_access
  end

  def current_user_name
    profile = current_user_profile

    profile&.[](:name).presence ||
      [profile&.[](:given_name), profile&.[](:family_name)].compact.join(" ").presence ||
      profile&.[](:nickname).presence ||
      profile&.[](:email).presence
  end

  def logged_in_using_omniauth?
    current_user_profile.present?
  end

  def auth0_configured?
    Rails.configuration.x.auth0.domain.present? &&
      Rails.configuration.x.auth0.client_id.present? &&
      Rails.configuration.x.auth0.client_secret.present?
  end

  def tailwind_stylesheet_available?
    Rails.root.join("app/assets/builds/tailwind.css").exist?
  end
end

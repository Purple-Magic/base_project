credentials = Rails.application.credentials

def auth0_credential_value(credentials, *path_candidates)
  path_candidates.lazy.map do |path|
    path.reduce(credentials) do |memo, key|
      break nil if memo.nil?

      if memo.respond_to?(:[])
        memo[key] || memo[key.to_s] || memo[key.to_sym]
      elsif memo.respond_to?(key)
        memo.public_send(key)
      end
    end
  end.find(&:presence)
end

current_environment = Rails.env.to_sym

auth0_domain = auth0_credential_value(
  credentials,
  [current_environment, :auth0, :domain],
  [Rails.env, "auth0", "domain"],
  [:auth0, :domain],
  ["auth0", "domain"],
  [current_environment, :auth0_domain],
  [Rails.env, "auth0_domain"],
  [:auth0_domain],
  ["auth0_domain"]
) || ENV["AUTH0_DOMAIN"].presence || (Rails.env.test? ? "test.auth0.local" : nil)

auth0_client_id = auth0_credential_value(
  credentials,
  [current_environment, :auth0, :client_id],
  [Rails.env, "auth0", "client_id"],
  [current_environment, :auth0, :cliend_id],
  [Rails.env, "auth0", "cliend_id"],
  [:auth0, :client_id],
  ["auth0", "client_id"],
  [:auth0, :cliend_id],
  ["auth0", "cliend_id"],
  [current_environment, :auth0_client_id],
  [Rails.env, "auth0_client_id"],
  [current_environment, :auth0_cliend_id],
  [Rails.env, "auth0_cliend_id"],
  [:auth0_client_id],
  ["auth0_client_id"],
  [:auth0_cliend_id],
  ["auth0_cliend_id"]
) || ENV["AUTH0_CLIENT_ID"].presence || (Rails.env.test? ? "test-client-id" : nil)

auth0_client_secret = auth0_credential_value(
  credentials,
  [current_environment, :auth0, :client_secret],
  [Rails.env, "auth0", "client_secret"],
  [:auth0, :client_secret],
  ["auth0", "client_secret"],
  [current_environment, :auth0_client_secret],
  [Rails.env, "auth0_client_secret"],
  [:auth0_client_secret],
  ["auth0_client_secret"]
) || ENV["AUTH0_CLIENT_SECRET"].presence || (Rails.env.test? ? "test-client-secret" : nil)

Rails.configuration.x.auth0 = ActiveSupport::OrderedOptions.new
Rails.configuration.x.auth0.domain = auth0_domain
Rails.configuration.x.auth0.client_id = auth0_client_id
Rails.configuration.x.auth0.client_secret = auth0_client_secret

OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.silence_get_warning = true

if auth0_domain.present? && auth0_client_id.present? && auth0_client_secret.present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider(
      :auth0,
      auth0_client_id,
      auth0_client_secret,
      auth0_domain,
      callback_path: "/auth/auth0/callback",
      authorize_params: {
        scope: "openid profile"
      }
    )
  end
else
  message = "Auth0 credentials are not configured. Expected Rails credentials auth0.domain, auth0.client_id or auth0.cliend_id, and auth0.client_secret."

  if Rails.env.test?
    Rails.logger.warn(message)
  else
    raise message
  end
end

RSpec.configure do |config|
  config.before do
    OmniAuth.config.mock_auth[:auth0] = nil
  end
end

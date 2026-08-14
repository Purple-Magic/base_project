describe Auth0Controller, type: :controller do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: 'auth0',
      uid: 'auth0|123',
      extra: {
        raw_info: {
          'sub' => 'auth0|123',
          'name' => 'Ada Lovelace',
          'email' => 'ada@example.com'
        }
      }
    )
  end

  describe '#callback' do
    it 'stores the Auth0 raw profile in the session and redirects to the profile page' do
      request.env['omniauth.auth'] = auth_hash

      get :callback

      expect(response).to redirect_to(user_path)
      expect(session[:userinfo]).to include(
        'sub' => 'auth0|123',
        'name' => 'Ada Lovelace',
        'email' => 'ada@example.com'
      )
    end
  end

  describe '#logout' do
    it 'clears the session and redirects to the Auth0 logout endpoint' do
      session[:userinfo] = { 'sub' => 'auth0|123' }

      get :logout

      expect(response).to redirect_to(
        'https://test.auth0.local/v2/logout?client_id=test-client-id&returnTo=http%3A%2F%2Ftest.host%2F'
      )
      expect(session[:userinfo]).to be_nil
    end

    it 'supports logging out with a delete request' do
      session[:userinfo] = { 'sub' => 'auth0|123' }

      delete :logout

      expect(response).to redirect_to(
        'https://test.auth0.local/v2/logout?client_id=test-client-id&returnTo=http%3A%2F%2Ftest.host%2F'
      )
      expect(session[:userinfo]).to be_nil
    end
  end
end

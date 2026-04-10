describe 'Users Show Page', type: :feature do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
      provider: 'auth0',
      uid: 'auth0|123',
      info: {
        name: 'Ada Lovelace',
        email: 'ada@example.com'
      },
      extra: {
        raw_info: {
          'sub' => 'auth0|123',
          'name' => 'Ada Lovelace',
          'nickname' => 'ada',
          'email' => 'ada@example.com'
        }
      }
    )
  end

  after do
    OmniAuth.config.mock_auth[:auth0] = nil
    OmniAuth.config.test_mode = false
  end

  it 'redirects guests back to the home page' do
    visit user_path

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Please log in to continue.')
  end

  it 'shows the Auth0 profile after login' do
    visit root_path

    click_on 'Login'

    expect(page).to have_current_path(user_path)
    expect(page).to have_content('You have been logged in successfully.')
    expect(page).to have_content('Your profile')
    expect(page).to have_content('Ada Lovelace')
    expect(page).to have_content('ada@example.com')
    expect(page).to have_content('auth0|123')
    expect(page).to have_link('Profile', href: user_path)
    expect(page).to have_button('Logout')
  end
end

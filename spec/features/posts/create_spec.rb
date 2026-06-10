describe 'Posts Create Page', type: :feature do
  let!(:user) { create(:user) }

  it 'creates a new post' do
    visit new_post_path

    fill_in 'Content', with: 'My new post content'
    fill_in 'User', with: user.id
    find('input[type=submit], button[type=submit]').click

    expect(page).to have_content('My new post content')
  end
end

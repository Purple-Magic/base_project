describe 'Posts Update Page', type: :feature do
  let!(:post) { create(:post) }

  it 'updates an existing post' do
    visit edit_post_path(post)

    fill_in 'Content', with: 'Updated content'
    find('input[type=submit], button[type=submit]').click

    expect(page).to have_content('Updated content')
  end
end

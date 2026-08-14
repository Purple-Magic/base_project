describe 'Posts Create Page', type: :feature do
  let!(:user) { create(:user) }

  it 'creates a new post' do
    visit new_post_path

    expect do
      fill_in 'Content', with: 'My new post content'
      select user.full_name, from: 'User'
      find('input[type=submit], button[type=submit]').click
    end.to change(Post, :count).by(1)

    expect(page).to have_content('My new post content')

    post = Post.last
    expect(post.content).to eq('My new post content')
    expect(post.user).to eq(user)
  end
end

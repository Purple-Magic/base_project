describe 'Posts Index Page', type: :feature do
  let!(:post) { create(:post) }

  it 'lists posts' do
    visit posts_path

    expect(page).to have_content(post.content)
  end
end

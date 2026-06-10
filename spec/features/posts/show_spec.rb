describe 'Posts Show Page', type: :feature do
  let!(:post) { create(:post) }

  it 'shows post details' do
    visit post_path(post)

    expect(page).to have_content(post.content)
  end
end

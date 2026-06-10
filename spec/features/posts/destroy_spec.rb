describe 'Posts Destroy', type: :feature do
  let!(:post) { create(:post) }

  it 'deletes a post' do
    visit posts_path

    expect(page).to have_content(post.content)

    visit post_path(post)
    click_on 'Destroy'

    expect(page).not_to have_content(post.content)
  end
end

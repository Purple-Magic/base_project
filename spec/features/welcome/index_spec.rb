require 'rails_helper'

describe 'Welcome Index Page', type: :feature do
  let!(:product_chat) { create(:chat, name: 'Product Planning') }
  let!(:support_chat) { create(:chat, name: 'Support Queue') }

  before do
    create(:user, first_name: 'Alice', last_name: 'Johnson', chats: [product_chat])
    create(:user, first_name: 'Bob', last_name: 'Miller', chats: [product_chat, support_chat])
  end

  it 'displays chats on the root page and links to show pages' do
    visit root_path

    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Chats')
    expect(page).to have_content('Product Planning')
    expect(page).to have_content('Support Queue')
    expect(page).to have_link('Product Planning', href: chat_path(product_chat))
    expect(page).to have_link('Support Queue', href: chat_path(support_chat))
    expect(page).to have_content('2 members')
    expect(page).to have_content('1 member')
  end
end

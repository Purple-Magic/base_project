require 'rails_helper'

describe 'Chats Show Page', type: :feature do
  let!(:chat) { create(:chat, name: 'Product Planning') }
  let!(:alice) { create(:user, first_name: 'Alice', last_name: 'Johnson', chats: [chat]) }
  let!(:bob) { create(:user, first_name: 'Bob', last_name: 'Miller', chats: [chat]) }

  it 'displays the chat details and members' do
    visit chat_path(chat)

    expect(page).to have_current_path(chat_path(chat))
    expect(page).to have_content('Product Planning')
    expect(page).to have_content(chat.uuid)
    expect(page).to have_content('2 members')
    expect(page).to have_content('in this chat')
    expect(page).to have_content('Alice Johnson')
    expect(page).to have_content('Bob Miller')
    expect(page).to have_content("Hi, I'm Alice Johnson.")
    expect(page).to have_content("Hi, I'm Bob Miller.")
  end
end

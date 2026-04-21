require 'rails_helper'

describe 'Chats::MessagesController#index', type: :request do
  let(:headers) do
    {
      'ACCEPT' => Mime[:turbo_stream].to_s,
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
    }
  end

  let!(:creator) { create(:user, first_name: 'Alice', last_name: 'Johnson') }
  let!(:chat) { create(:chat, name: 'Support Queue', creator:) }
  let!(:member) { create(:user, first_name: 'Bob', last_name: 'Miller', chats: [chat]) }

  before do
    host! 'localhost'
    creator.chats << chat

    25.times do |index|
      sender = index.even? ? creator : member

      Chats::Message.create!(
        chat:,
        sender:,
        text: "Message #{index + 1}",
        uuid: SecureRandom.uuid
      )
    end
  end

  it 'returns ok when the requested older page is broadcast' do
    get chats_messages_path,
      params: { chat_id: chat.uuid, page: 2 },
      headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.body).to be_blank
  end

  it 'returns no content when there are no more history pages' do
    get chats_messages_path,
      params: { chat_id: chat.uuid, page: 99 },
      headers: headers

    expect(response).to have_http_status(:no_content)
  end
end

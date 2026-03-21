class Chats::Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :chat, class_name: 'Chat'

  after_create -> do
    tramway_chat_append_message chat_id: chat.uuid,
      type: :sent,
      text:,
      sent_at: I18n.l(created_at, format: :long)
  end
end

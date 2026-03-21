class CreateChatsMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :chats_messages do |t|
      t.bigint :chat_id
      t.bigint :sender_id
      t.string :text
      t.uuid :uuid, default: -> { "uuid_generate_v4()" }

      t.timestamps
    end
  end
end

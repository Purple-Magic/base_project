class CreateChatsUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :chats_users do |t|
      t.bigint :chat_id
      t.bigint :user_id

      t.timestamps
    end
  end
end

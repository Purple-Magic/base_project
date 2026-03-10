class CreateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.uuid :uuid, default: -> { "uuid_generate_v4()" }

      t.timestamps
    end
  end
end

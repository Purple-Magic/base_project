class AddNameToChats < ActiveRecord::Migration[8.1]
  class MigrationChat < ApplicationRecord
    self.table_name = :chats
  end

  def up
    add_column :chats, :name, :string

    MigrationChat.reset_column_information
    MigrationChat.where(name: nil).find_each do |chat|
      chat.update_columns(name: "Chat #{chat.uuid.to_s.first(8)}")
    end

    change_column_null :chats, :name, false
  end

  def down
    remove_column :chats, :name, :string
  end
end

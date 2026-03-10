class EnsureChatsHaveUuid < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE chats
      SET uuid = uuid_generate_v4()
      WHERE uuid IS NULL
    SQL

    change_column_default :chats, :uuid, -> { 'uuid_generate_v4()' }
    change_column_null :chats, :uuid, false
  end

  def down
    change_column_null :chats, :uuid, true
    change_column_default :chats, :uuid, nil
  end
end

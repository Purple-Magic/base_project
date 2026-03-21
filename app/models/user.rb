class User < ApplicationRecord
  has_and_belongs_to_many :chats
  has_many :messages, class_name: 'Chats::Message', dependent: :destroy, foreign_key: 'sender_id'

  validates :first_name, :last_name, presence: true

  def full_name
    [first_name, last_name].join(' ')
  end
end

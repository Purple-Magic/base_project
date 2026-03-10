class User < ApplicationRecord
  has_and_belongs_to_many :chats

  validates :first_name, :last_name, presence: true

  def full_name
    [first_name, last_name].join(' ')
  end
end

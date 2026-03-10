class Chat < ApplicationRecord
  has_and_belongs_to_many :users

  scope :with_members, -> { includes(:users) }

  before_validation :ensure_uuid, on: :create

  validates :name, presence: true
  validates :uuid, presence: true

  def to_param
    uuid
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end

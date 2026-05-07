class UserDecorator < Tramway::BaseDecorator
  delegate_attributes :chats, :first_name, :last_name

  class << self
    def index_attributes
      %i[id full_name chats_count]
    end
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  alias title full_name

  def chats_count
    chats.size
  end
end

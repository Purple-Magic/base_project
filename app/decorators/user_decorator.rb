class UserDecorator < Tramway::BaseDecorator
  delegate_attributes :chats, :first_name, :last_name

  def full_name
    [first_name, last_name].join(' ')
  end

  def chats_count
    chats.size
  end
end

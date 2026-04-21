class ChatDecorator < Tramway::BaseDecorator
  MESSAGES_PER_PAGE = 20

  delegate_attributes :created_at, :name, :updated_at, :users, :uuid

  def title
    name
  end

  def show_path
    chat_path(object)
  end

  def members_count
    users.size
  end

  def transcript_messages(page: 1)
    paginated_messages(page).map do |message|
      {
        id: message.uuid,
        type: message.sender_id == object.creator_id ? :sent : :received,
        text: message.text,
        sent_at: message.created_at,
      }
    end
  end

  private

  def paginated_messages(page)
    Chats::Message.where(chat: object)
                  .order(created_at: :desc, id: :desc)
                  .page(page)
                  .per(MESSAGES_PER_PAGE)
                  .reverse
  end

  def ordered_users
    users.sort_by { |user| [user.first_name.to_s, user.last_name.to_s] }
  end

  def display_name(user)
    [user.first_name, user.last_name].join(' ').strip
  end
end

class ChatDecorator < Tramway::BaseDecorator
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

  def transcript_messages
    return [empty_state_message] if users.empty?

    ordered_users.each_with_index.map do |user, index|
      {
        id: "chat-#{uuid}-message-#{index}",
        type: index.even? ? :received : :sent,
        text: "Hi, I'm #{display_name(user)}.",
        sent_at: created_at + index.minutes
      }
    end
  end

  private

  def ordered_users
    users.sort_by { |user| [user.first_name.to_s, user.last_name.to_s] }
  end

  def display_name(user)
    [user.first_name, user.last_name].join(' ').strip
  end

  def empty_state_message
    {
      id: "chat-#{uuid}-empty",
      type: :received,
      text: 'This chat does not have any members yet.',
      sent_at: created_at || Time.current
    }
  end
end

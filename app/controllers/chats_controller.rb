class ChatsController < ApplicationController
  def show
    chat = Chat.with_members.find_by!(uuid: params[:uuid])

    @chat = tramway_decorate(chat)
    @members = tramway_decorate(chat.users.sort_by { |user| [user.first_name.to_s, user.last_name.to_s] })
    @message_form = tramway_form chat.creator.messages.build
  end
end

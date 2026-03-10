class ChatsController < ApplicationController
  def show
    chat = Chat.with_members.find_by!(uuid: params[:uuid])

    @chat = tramway_decorate(chat).with(view_context:)
    @members = tramway_decorate(chat.users.sort_by { |user| [user.first_name.to_s, user.last_name.to_s] })
  end
end

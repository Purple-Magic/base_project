class Chats::MessagesController < ApplicationController
  def create
    chat = Chat.find_by uuid: params[:message][:chat_id]

    @message = tramway_form chat.creator.messages.build(chat:)

    if @message.submit params[:message]
    end
  end
end

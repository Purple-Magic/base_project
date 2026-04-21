class Chats::MessagesController < ApplicationController
  def index
    chat = Chat.find_by!(uuid: params[:chat_id])

    messages = tramway_decorate(chat).transcript_messages(page: params[:page])

    return head :no_content if messages.blank?

    tramway_chat_prepend_messages(chat_id: chat.uuid, messages:)

    head :ok
  end

  def create
    chat = Chat.find_by uuid: params[:message][:chat_id]

    @message = tramway_form chat.creator.messages.build(chat:)

    if @message.submit params[:message]
    end
  end
end

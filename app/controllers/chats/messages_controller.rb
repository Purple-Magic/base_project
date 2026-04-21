class Chats::MessagesController < ApplicationController
  def index
    chat = Chat.find_by(uuid: params[:chat_id])

    messages = tramway_decorate(chat).transcript_messages(page: params[:page])

    return head :no_content if messages.blank?

    render turbo_stream: turbo_stream.prepend(
      'messages',
      partial: 'tramway/chats/messages',
      locals: { messages: }
    )
  end

  def create
    chat = Chat.find_by uuid: params[:message][:chat_id]

    @message = tramway_form chat.creator.messages.build(chat:)

    if @message.submit params[:message]
    end
  end
end

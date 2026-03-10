class WelcomeController < ApplicationController
  def index
    chats = Chat.with_members.order(:name)

    @chats = tramway_decorate(chats)
  end
end

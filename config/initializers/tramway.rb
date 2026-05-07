Tramway.configure do |config|
  config.application_controller = "ApplicationController"

  config.entities = [
    {
      name: :user,
      pages: [
        { action: :index },
        { action: :show },
        { action: :create },
        { action: :update },
        { action: :destroy }
      ]
    },
    {
      name: :chat,
      pages: [
        { action: :index },
        { action: :show },
        { action: :create },
        { action: :update },
        { action: :destroy }
      ]
    }
  ]
end

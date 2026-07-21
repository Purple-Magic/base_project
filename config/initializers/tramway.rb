Tramway.configure do |config|
  config.application_controller = "ApplicationController"
  config.entities = [
    {
      name: :post,
      pages: [
        { action: :index },
        { action: :show },
        { action: :create },
        { action: :update },
        { action: :destroy }
      ]
    },
    {
      name: :survey,
      pages: [
        { action: :index },
        { action: :show },
        { action: :create },
        { action: :update },
        { action: :destroy }
      ]
    },
    {
      name: 'surveys/question',
      pages: [
        { action: :create },
        { action: :show },
        { action: :update },
        { action: :destroy },
      ]
    }
  ]
end

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
    }
  ]
end

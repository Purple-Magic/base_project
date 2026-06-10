Rails.application.routes.draw do
  root to: "welcome#index"
  get "/auth/auth0/callback", to: "auth0#callback", as: :auth0_callback
  get "/auth/failure", to: "auth0#failure", as: :auth0_failure
  get "/auth/logout", to: "auth0#logout", as: :auth0_logout
  namespace :chats do
    resources :messages, only: %i[index create]
  end
  resources :chats, only: :show, param: :uuid

  resource :user, only: :show

  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.development?
    post "/dev/login", to: "dev/sessions#create", as: :dev_login
  end

  mount Tramway::Engine, at: "/"
end

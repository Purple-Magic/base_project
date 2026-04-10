Rails.application.routes.draw do
  root to: "welcome#index"
  get "/auth/auth0/callback", to: "auth0#callback", as: :auth0_callback
  get "/auth/failure", to: "auth0#failure", as: :auth0_failure
  get "/auth/logout", to: "auth0#logout", as: :auth0_logout
  resources :chats, only: :show, param: :uuid
  namespace :chats do
    resources :messages, only: :create
  end

  resource :user, only: :show

  get "up" => "rails/health#show", as: :rails_health_check
end

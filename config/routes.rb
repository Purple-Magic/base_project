Rails.application.routes.draw do
  root to: "welcome#index"
  resources :chats, only: :show, param: :uuid
  namespace :chats do
    resources :messages, only: :create
  end

  get "up" => "rails/health#show", as: :rails_health_check
end

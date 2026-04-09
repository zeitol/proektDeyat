Rails.application.routes.draw do
  devise_for :users
  root "posts#index"

  resources :posts, only: [:index, :create]
  resources :users, only: [:show]
end
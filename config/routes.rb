Rails.application.routes.draw do
  devise_for :users
  root "posts#index"
resources :posts, only: [:index, :create, :edit, :update, :destroy, :show] do
  resources :comments, only: [:create, :destroy]
  resources :likes, only: [:create, :destroy]
end
  #resources :posts, only: [:index, :create, :edit, :update, :destroy]
  resources :users, only: [:show, :edit, :update]
end
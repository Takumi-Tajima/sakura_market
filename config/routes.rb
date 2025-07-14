Rails.application.routes.draw do
  devise_for :users
  devise_for :admins, controllers: { sessions: 'admins/sessions', passwords: 'admins/passwords' }

  root 'foods#index'

  resources :foods, only: %i[index show]

  namespace :admins do
    root 'foods#index'
    resources :foods
    resources :orders, only: %i[index show]
    resources :users, only: %i[index show edit update destroy]
  end

  namespace :users do
    resource :cart, only: %i[show] do
      resources :cart_items, only: %i[new create edit update destroy], module: :carts
    end
    resources :orders, only: %i[index show new create]
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end

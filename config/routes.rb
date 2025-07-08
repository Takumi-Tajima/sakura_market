Rails.application.routes.draw do
  devise_for :admins
  root 'home#index'

  namespace :admins do
    root 'home#index'
  end
end

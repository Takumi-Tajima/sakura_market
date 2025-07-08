Rails.application.routes.draw do
  devise_for :admins, controllers: { sessions: 'admins/sessions' }

  root 'home#index'

  namespace :admins do
    root 'home#index'
  end
end

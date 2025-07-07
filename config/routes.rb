Rails.application.routes.draw do
  root 'home#index'

  namespace :admins do
    root 'home#index'
  end
end

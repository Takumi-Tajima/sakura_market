Rails.application.routes.draw do
  devise_for :users
  devise_for :admins, controllers: { sessions: 'admins/sessions' }

  root 'foods#index'

  resources :foods, only: %i[index show]

  namespace :admins do
    root 'foods#index'
    resources :foods
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end

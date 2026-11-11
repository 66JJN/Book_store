Rails.application.routes.draw do
  root "books#index"

  resource :session, only: %i[new create destroy]
  resources :books, only: %i[index show]

  namespace :admin do
    root "dashboard#index"
    resources :books, except: :show
    resources :categories
    resources :markets
    resources :users, only: %i[index new create edit update destroy]
  end

  namespace :api, defaults: { format: :json } do
    resource :session, only: %i[create destroy]
    resources :books, except: %i[new edit]
    resources :categories, except: %i[new edit]
    resources :markets, except: %i[new edit]
    resources :users, only: %i[index show create update destroy]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

end

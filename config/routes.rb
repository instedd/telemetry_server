Rails.application.routes.draw do
  devise_for :users, except: [:registrations]

  namespace :api, defaults: {format: :json} do
    scope :v1 do
      resources :installations, only: [:update] do
        resources :events, only: [:create]
      end
    end
  end

  resources :installations, only: [:index, :destroy] do
    resources :tags, only: [:create, :destroy], controller: 'installation_tags'

    resources :events, only: [:index] do
      member do
        get :errors
      end
    end
  end

  resources :dashboard, only: [:index]

  root to: "installations#index"

  mount Listings::Engine => "/listings"

  authenticate :user do
    mount KibanaProxy.new(streaming: false) => "/kibana"
  end

  if Rails.application.config.active_job.queue_adapter.eql? :sidekiq
    require 'sidekiq/web'
    authenticate :user do
      mount Sidekiq::Web => '/sidekiq'
    end
  end
end

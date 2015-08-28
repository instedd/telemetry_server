Rails.application.routes.draw do
  namespace :api, defaults: {format: :json} do
    scope :v1 do
      resources :installations, only: [:update] do
        resources :events, only: [:create]
      end
    end
  end
end

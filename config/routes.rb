Rails.application.routes.draw do
  root "pages#home"

  post "/s", to: "short_urls#create", as: :create_short_url

  get "/:short_code/stats", to: "analytics#show", as: :analytics,
      constraints: { short_code: /[a-zA-Z0-9_-]{1,15}/ }

  namespace :api do
    namespace :v1 do
      resources :short_urls, only: %i[create show], param: :short_code do
        member { get :analytics }
      end
    end
  end

  get "/health", to: "health#show"

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"       => "rails/pwa#manifest",       as: :pwa_manifest

  get "/:short_code", to: "redirects#show",
      constraints: { short_code: /[a-zA-Z0-9_-]{1,15}/ }
end

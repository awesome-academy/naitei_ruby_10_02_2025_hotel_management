Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "static_pages/home"
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    get "/logout", to: "sessions#destroy"


    get "sessions/new"
    get "sessions/create"
    get "sessions/destroy"
    scope "admin" do
      resources :room_types do
        delete "images/:image_id", to: "room_types#destroy_image", as: "image"
      end
      resources :rooms
      resources :requests, only: %i(index show) do
        member do
          get "checkin"
          post "checkin/submit", to: "requests#checkin_submit"
          get "deny"
          post "deny/submit", to: "requests#deny_submit"
          get "checkout"
          post "checkout/submit", to: "requests#checkout_submit"
        end
      end
      resources :services
      resources :users do
        member do
          put "activate"
          put "deactivate"
        end
      end
    end
    scope :user, module: :user, as: :user do
      get "room_types", to: "room_types#index", as: "room_types"
      get "room_types/:id", to: "room_types#show", as: "room_type"
    
      resources :requests, only: [:new, :create, :show, :index] do
        member do
          post "expire"           
          get  "status_check"     
        end

        collection do
          get "check_availability" 
        end
      end
      resources :reviews, only: [:index, :new, :create]
    end
  end
end

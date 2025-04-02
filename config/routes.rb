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
      resources :room_types
    end
    scope :user do
      get "room_types", to: "user/room_types#index", as: "user_room_types"
      get "room_types/:id", to: "user/room_types#show", as: "user_room_type"
    end
  end
end

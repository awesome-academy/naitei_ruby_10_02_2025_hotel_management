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
  end
end

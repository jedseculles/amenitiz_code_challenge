Rails.application.routes.draw do
  # Cart endpoints (store-facing only)
  post "cart/add", to: "carts#add", as: :add_to_cart
  delete "cart/remove/:product_id", to: "carts#remove", as: :remove_from_cart
  get "cart", to: "carts#show", as: :cart
  delete "cart/clear", to: "carts#clear", as: :clear_cart

  resources :products

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
end

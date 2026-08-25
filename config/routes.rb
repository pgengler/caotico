Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :posts, only: [ :index, :show ]
  namespace :admin do
    resources :posts
  end
  get '/posts/:id/*slug' => 'posts#show'
  get 'tags/:tag', to: 'posts#index', as: :tag

  get '/about' => 'static_pages#about'

  root :to => "posts#index"
end

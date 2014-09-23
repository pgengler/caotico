Rails.application.routes.draw do
  resources :posts, only: [ :index, :show ]
  namespace :admin do
    resources :posts
  end
  get '/posts/:id/*slug' => 'posts#show'
  get 'tags/:tag', to: 'posts#index', as: :tag

  get '/about' => 'static_pages#about'

  root :to => "posts#index"
end

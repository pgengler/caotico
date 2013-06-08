Caotico::Application.routes.draw do
  resources :posts
  resources :static_pages
  get '/posts/:id/*slug' => 'posts#show'
  get 'tags/:tag', to: 'posts#index', as: :tag

  get '/about' => 'static_pages#about'

  root :to => "posts#index"
end

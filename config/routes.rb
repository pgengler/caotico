Caotico::Application.routes.draw do
  resources :posts
  get '/posts/:id/*slug' => 'posts#show'
  get 'tags/:tag', to: 'posts#index', as: :tag

  root :to => "posts#index"
end

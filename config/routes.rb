Caotico::Application.routes.draw do
  resources :posts
  get '/posts/:id/*slug' => 'posts#show'

  root :to => "posts#index"
end

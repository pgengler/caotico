Caotico::Application.routes.draw do
  resources :posts
  match '/posts/:id/*slug' => 'posts#show'
  get '/feed(.:format)' => 'posts#feed'

  root :to => "posts#index"
end

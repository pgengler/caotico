Caotico::Application.routes.draw do
  resources :posts
  match '/posts/:id/*slug' => 'posts#show'

  root :to => "posts#index"
end

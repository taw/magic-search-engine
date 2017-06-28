Rails.application.routes.draw do
  get "card/gallery/:set/:id" => "card#gallery"
  get "card/:set/:id" => "card#show"
  get "card/:set/:id/:name" => "card#show"
  get "card" => "card#index"
  get "set/:id" => "set#show"
  get "set" => "set#index"
  get "artist/:id" => "artist#show"
  get "artist" => "artist#index"
  get "format/:id" => "format#show"
  get "format" => "format#index"
  get "help/syntax" => "help#syntax"
  get "help/rules" => "help#rules"
  get "help/contact" => "help#contact"
  get "/" => "card#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

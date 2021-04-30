Rails.application.routes.draw do
  get "/pages/*page" => "pages#show"
  get "/testpage-redirect-origin" => "redirects#show"
  get "/*page" => "pages#show"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

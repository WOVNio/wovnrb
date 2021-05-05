Rails.application.routes.draw do
  get "/redirecting_page" => "redirects#show"
  get "/*page" => "pages#show"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

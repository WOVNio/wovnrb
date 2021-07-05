Rails.application.routes.draw do
  get "/redirecting_page" => "redirects#show"
  get "/custom_response" => "custom_response#make_response"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

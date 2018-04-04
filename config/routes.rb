Rails.application.routes.draw do
  resources :observations, only: [:index, :show, :new]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "observations#index"
end

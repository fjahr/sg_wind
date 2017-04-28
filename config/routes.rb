Rails.application.routes.draw do
  resources :observations, only: [:index, :show, :new]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  Rails.application.routes.draw do
    mount Facebook::Messenger::Server, at: "bot"
  end

  root to: "observations#index"
end

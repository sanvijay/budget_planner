Rails.application.routes.draw do
  resources :users, only: [:show, :create, :destroy], param: :user_id do
    member do
      resources :assets
      resources :goals
      resources :categories
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

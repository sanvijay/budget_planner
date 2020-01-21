Rails.application.routes.draw do
  match 'login', to: 'users#login', via: [:post]

  resources :users, only: [:show, :create, :destroy], param: :user_id do
    member do
      resources :assets, :goals, :categories
      resource :user_profiles, only: [:show, :update]

      resources :monthly_budgets, except: [:show, :update, :destroy] do
        resources :cash_flows, only: [:index]
        resources :cash_flows, only: [:create], path: 'planned_cash_flows'
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

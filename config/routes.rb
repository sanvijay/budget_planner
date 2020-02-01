Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    confirmations: 'confirmations'
  }

  resources :users, only: [], param: :user_id do
    member do
      resources :assets, :goals, :categories, :benefits
      resource :user_profile, only: %i[show update]
      resource :custom_rule, only: %i[show update]

      resources :monthly_budgets, except: %i[show update destroy] do
        resources :cash_flows, only: [:index]
        resources :cash_flows, only: [:create], path: 'planned_cash_flows'
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

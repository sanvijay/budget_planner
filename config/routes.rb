Rails.application.routes.draw do
  resources :feedbacks, only: %i[create]
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    confirmations: 'confirmations',
    passwords: 'passwords'
  }

  resources :users, only: [], param: :user_id do
    member do
      resources :assets, :goals, :categories, :benefits
      resource :user_profile, only: %i[show update]
      resource :custom_rule, only: %i[show update]

      resources :monthly_budgets, except: %i[show update destroy] do
        resources :cash_flows, only: %i[index create]
        resources :actual_cash_flow_logs, only: %i[create]
        collection do
          post 'create_planned_cash_flow_batch', to: "cash_flows#create_batch"
        end
      end
      get 'all_financial_years', to: "monthly_budgets#all_financial_years"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

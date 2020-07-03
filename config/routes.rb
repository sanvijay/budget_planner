Rails.application.routes.draw do
  resources :personal_advisor_requests, only: %i[create]
  resources :quizs, only: %i[create update]

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
      resources :phone_numbers, only: [:create, :index] do
        collection do
          post :verify, to: "phone_numbers#verify"
        end
      end

      resources :assets, :goals, :categories, :benefits, :accounts, :loans
      resource :user_profile, only: %i[show update]

      resources :monthly_budgets, only: %i[index update] do
        resources :cash_flows, only: %i[index create]
        resources :actual_cash_flow_logs, only: %i[create index destroy]
        collection do
          post 'create_planned_cash_flow_batch', to: "cash_flows#create_batch"
          get'index_actual_cash_flow_logs_batch', to: 'actual_cash_flow_logs#index_batch'
        end
      end
      get 'all_financial_years', to: "monthly_budgets#all_financial_years"
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

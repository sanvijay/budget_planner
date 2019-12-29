class MonthlyBudgetsController < ApplicationController
  before_action :set_user
  before_action :set_monthly_budget, only: %i[show]

  # GET /monthly_budgets
  def index
    @monthly_budgets = @user.monthly_budgets

    render json: @monthly_budgets
  end

  # GET /monthly_budgets/1
  def show
    render json: @monthly_budget
  end

  # POST /monthly_budgets
  def create
    @monthly_budget = @user.monthly_budgets.build(monthly_budget_params)

    if @monthly_budget.save
      render json: @monthly_budget, status: :created
    else
      render json: @monthly_budget.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_monthly_budget
    @monthly_budget = @user.monthly_budgets.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def monthly_budget_params
    params.require(:monthly_budget).permit(:month)
  end
end

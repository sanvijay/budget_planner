class MonthlyBudgetsController < ApplicationController
  before_action :set_user
  before_action :set_monthly_budget, only: %i[show]

  # GET /monthly_budgets
  def index
    if params[:year].blank?
      render json: { message: "Params: year is required" }, status: :bad_request
    else
      render json: yearly_budgets
    end
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

  def method_name
    ((((@date[month] ||= {})[day] ||= {})[hours] ||= {})[min] ||= {})[sec] = 1
  end

  def yearly_budgets
    yearly_budgets = @user.monthly_budgets.of_the_year(params[:year].to_i)

    @results = {}
    yearly_budgets.each do |budget|
      budget.expected_cash_flows.each do |cf|
        deep_hash_budgets(budget, cf)
      end
    end

    @results
  end

  def deep_hash_budgets(budget, cash_flow)
    (
      (
        (
          @results[cash_flow.category.type] ||= {}
        )[cash_flow.category.title] ||= {}
      )[budget.month.year] ||= {}
    )[budget.month.month] ||= { "value": cash_flow.value }
  end
end

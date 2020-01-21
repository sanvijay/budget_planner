class MonthlyBudgetsController < ApplicationController
  before_action :set_user

  # GET /monthly_budgets
  def index
    if params[:year].blank?
      render json: { message: "Params: year is required" }, status: :bad_request
    else
      render json: yearly_budgets
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def yearly_budgets
    yearly_budgets = @user.monthly_budgets.of_the_year(params[:year].to_i)

    @results = {}
    yearly_budgets.each do |budget|
      budget.planned_cash_flows.each do |cf|
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
        )[cash_flow.category.id] ||= {}
      )[budget.month.year] ||= {}
    )[budget.month.month] ||= { "value": cash_flow.value }
  end
end

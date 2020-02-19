class MonthlyBudgetsController < ApplicationController
  before_action :set_user

  # GET /monthly_budgets
  def index
    if params[:financial_year].blank?
      render json: { message: "Params: year is required" }, status: :bad_request
    else
      render json: yearly_budgets
    end
  end

  # GET all_financial_years
  def all_financial_years
    first = @user.monthly_budgets.min(:month)
    last  = @user.monthly_budgets.max(:month)

    first_year = first.month <= 4 ? first.year - 1 : first.year
    last_year  = last.month > 4 ? last.year : last.year - 1

    render json: (first_year..last_year).to_a
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def yearly_budgets
    yearly_budgets = @user.monthly_budgets.of_the_financial_year(
      params[:financial_year].to_i
    )

    @results = {}
    yearly_budgets.each do |budget|
      budget.cash_flows.each do |cf|
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
    )[budget.month.month] ||= cash_flow_details(cash_flow)
  end

  def cash_flow_details(cash_flow)
    {
      "planned": cash_flow.planned,
      "actual": cash_flow.actual,
      "id": cash_flow.to_param,
      "logs": cash_flow.logs
    }
  end
end

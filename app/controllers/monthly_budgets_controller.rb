class MonthlyBudgetsController < ApplicationController
  before_action :set_user
  before_action :set_monthly_budget, only: %i[update]

  # GET /monthly_budgets
  def index
    if params[:financial_year].blank?
      render json: { message: "Params: financial_year is required" },
             status: :bad_request
    else
      render json: yearly_budgets
    end
  end

  # PATCH/PUT /monthly_budgets/1
  def update
    if @monthly_budget.update(monthly_budget_params)
      render json: @monthly_budget
    else
      render json: @monthly_budget.errors, status: :unprocessable_entity
    end
  end

  # GET all_financial_years
  def all_financial_years # rubocop:disable Metrics/AbcSize
    first = @user.monthly_budgets.min(:month)
    return render json: [] if first.nil?

    last = @user.monthly_budgets.max(:month)

    first_year = first.month <= 3 ? first.year - 1 : first.year
    last_year  = last.month > 3 ? last.year : last.year - 1

    render json: (first_year..last_year).to_a
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_monthly_budget
    if (date = parse_date)
      @monthly_budget = @user.monthly_budgets.of_the_month(date).first ||
                        @user.monthly_budgets.create!(month: date)
    else
      render json: {
        message: "Params: id should be of format MMYYYY"
      }, status: :bad_request
    end
  end

  def parse_date
    return unless (match = params[:id].match(/^(\d{2})(\d{4})$/))

    month, year = match.captures
    Date.new(year.to_i, month.to_i, 1)
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
          @results[budget.month.year] ||= {}
        )[budget.month.month] ||= prev_month_bal(budget)
      )[cash_flow.category.type] ||= {}
    )[cash_flow.category.id] ||= cash_flow_details(cash_flow)
  end

  def prev_month_bal(budget)
    {
      "prev_month_bal_actual": budget.prev_month_bal_actual,
      "prev_month_bal_planned": budget.prev_month_bal_planned
    }
  end

  def cash_flow_details(cash_flow)
    {
      "planned": cash_flow.planned,
      "actual": cash_flow.actual,
      "id": cash_flow.to_param,
      "logs": cash_flow.logs
    }
  end

  def monthly_budget_params
    params.require(:monthly_budget).permit(
      :prev_month_bal_planned,
      :prev_month_bal_actual
    )
  end
end

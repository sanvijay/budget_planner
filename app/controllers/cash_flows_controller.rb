class CashFlowsController < ApplicationController
  before_action :set_user, :set_monthly_budget
  before_action :set_category, :set_planned_cash_flows, only: %i[create]

  # GET /cash_flows
  def index
    @cash_flows = calculate_all_cash_flows

    render json: @cash_flows
  end

  # This is only for expected cashflow
  # If record is already there, update it.
  def create
    @planned_cash_flow ||= @monthly_budget.planned_cash_flows.build(
      category_id: @category.id
    )

    @planned_cash_flow.value = cash_flow_params[:value]

    if @planned_cash_flow.save
      render json: @planned_cash_flow, status: :created
    else
      render json: @planned_cash_flow.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_monthly_budget
    if (date = parse_date)
      @monthly_budget = @user.monthly_budgets.of_the_month(date).first ||
                        @user.monthly_budgets.create(month: date)
    else
      render json: {
        message: "Params: monthly_budget_id should be of format MMYYYY"
      }, status: :bad_request
    end
  end

  def parse_date
    return unless (match = params[:monthly_budget_id].match(/^(\d{2})(\d{4})$/))

    month, year = match.captures
    Date.new(year.to_i, month.to_i, 1)
  end

  def set_category
    @category = @user.categories.find(cash_flow_params[:category_id])
    return if @category

    render json: { message: "category_id should be valid" },
           status: :bad_request
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_planned_cash_flows
    @planned_cash_flow = @monthly_budget.planned_cash_flows.find_by(
      category_id: @category.id
    )
  end

  def cash_flow_params
    params[:cash_flow]
  end

  def calculate_all_cash_flows
    if params[:filter].blank? || params[:filter] == 'all'
      { expected: @monthly_budget.planned_cash_flows,
        actual: @monthly_budget.actual_cash_flows }

    elsif params[:filter] == 'expected'
      { expected: @monthly_budget.planned_cash_flows }

    elsif params[:filter] == 'actual'
      { actual: @monthly_budget.actual_cash_flows }

    end
  end
end

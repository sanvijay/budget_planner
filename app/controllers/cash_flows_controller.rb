class CashFlowsController < ApplicationController
  before_action :set_user, :set_monthly_budget
  before_action :set_actual_cash_flows, only: %i[show]
  before_action :set_expected_cash_flows, only: %i[update destroy]

  # GET /cash_flows
  def index
    @cash_flows = calculate_all_cash_flows

    render json: @cash_flows
  end

  # This is only for actual cashflow
  def show
    if @actual_cash_flow
      render json: @actual_cash_flow
    else
      render json: { message: "No record found." }, status: :not_found
    end
  end

  # This is only for expected cashflow
  def create
    @cash_flow = @monthly_budget.expected_cash_flows.build(cash_flow_params)

    if @cash_flow.save
      render json: @cash_flow, status: :created
    else
      render json: @cash_flow.errors, status: :unprocessable_entity
    end
  end

  # This is only for expected cashflow
  def update
    if @expected_cash_flow.nil?
      render json: { message: "No record found." }, status: :not_found
    elsif @expected_cash_flow.update(cash_flow_params)
      render json: @expected_cash_flow
    else
      render json: @expected_cash_flow.errors, status: :unprocessable_entity
    end
  end

  # This is only for expected cashflow
  def destroy
    if @expected_cash_flow.nil?
      render json: { message: "No record found." }, status: :not_found
    else
      @expected_cash_flow.destroy
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_monthly_budget
    @monthly_budget = @user.monthly_budgets.find(params[:monthly_budget_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_actual_cash_flows
    @actual_cash_flow = @monthly_budget.actual_cash_flows.find(params[:id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_expected_cash_flows
    @expected_cash_flow = @monthly_budget.expected_cash_flows.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cash_flow_params
    params.require(:cash_flow).permit(:category_id, :value)
  end

  def calculate_all_cash_flows
    if params[:filter].blank? || params[:filter] == 'all'
      { expected: @monthly_budget.expected_cash_flows,
        actual: @monthly_budget.actual_cash_flows }

    elsif params[:filter] == 'expected'
      { expected: @monthly_budget.expected_cash_flows }

    elsif params[:filter] == 'actual'
      { actual: @monthly_budget.actual_cash_flows }

    end
  end
end

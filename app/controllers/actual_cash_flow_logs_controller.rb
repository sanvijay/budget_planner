class ActualCashFlowLogsController < ApplicationController
  before_action :set_user
  before_action :set_monthly_budget, except: %i[index_batch]
  before_action :set_acfl, only: %i[destroy]

  # POST /actual_cash_flow_logs
  def create
    @actual_cash_flow_log = @monthly_budget.actual_cash_flow_logs
                                           .build(acfl_params)

    if @actual_cash_flow_log.save
      render json: @actual_cash_flow_log, status: :created
    else
      render json: @actual_cash_flow_log.errors, status: :unprocessable_entity
    end
  end

  def index
    @actual_cash_flow_logs = @monthly_budget.actual_cash_flow_logs

    render json: @actual_cash_flow_logs
  end

  def index_batch
    if params[:financial_year].blank?
      render json: { message: "Params: financial_year is required" },
             status: :bad_request
    else
      render json: yearly_logs
    end
  end

  def destroy
    @acfl.destroy
  end

  private

  def yearly_logs
    results = {}
    yearly_budgets.each do |budget|
      results[budget.month.year] ||= {}
      results[budget.month.year][budget.month.month] =
        budget.actual_cash_flow_logs.order_by(spent_on: :desc)
    end

    results
  end

  def yearly_budgets
    @user.monthly_budgets.of_the_financial_year(
      params[:financial_year].to_i
    )
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_monthly_budget
    if (date = parse_date)
      @monthly_budget = @user.monthly_budgets.of_the_month(date).first ||
                        @user.monthly_budgets.create!(month: date)
    else
      render json: {
        message: "Params: monthly_budget_id should be of format MMYYYY"
      }, status: :bad_request
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_acfl
    @acfl = @monthly_budget.actual_cash_flow_logs.find(params[:id])
  end

  def parse_date
    return unless (match = params[:monthly_budget_id].match(/^(\d{2})(\d{4})$/))

    month, year = match.captures
    Date.new(year.to_i, month.to_i, 1)
  end

  # Only allow a trusted parameter "white list" through.
  def acfl_params
    params.require(:actual_cash_flow_log).permit(
      :description,
      :value,
      :spent_on,
      :category_id,
      :account_id
    )
  end
end

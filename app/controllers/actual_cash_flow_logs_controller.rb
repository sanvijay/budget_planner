class ActualCashFlowLogsController < ApplicationController
  before_action :set_user, :set_monthly_budget

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
        message: "Params: monthly_budget_id should be of format MMYYYY"
      }, status: :bad_request
    end
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
      :spent_for,
      :category_id
    )
  end
end

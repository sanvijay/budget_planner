class CashFlowsController < ApplicationController
  before_action :set_user, :set_category
  before_action :set_monthly_budget, except: %i[create_batch]
  before_action :set_cash_flows, only: %i[create]

  # This is only for expected cashflow
  # If record is already there, update it.
  def create
    @cash_flow ||= @monthly_budget.cash_flows.build(
      category_id: @category.id
    )

    @cash_flow.planned = cash_flow_params[:planned]

    if @cash_flow.save
      render json: @cash_flow, status: :created
    else
      render json: @cash_flow.errors, status: :unprocessable_entity
    end
  end

  # This is only for expected cashflow
  # If record is already there, update it.
  def create_batch
    all_months.each do |month|
      cash_flow = find_or_build_cash_flow(month, @category.id)

      cash_flow.planned = cash_flow_params[:value]
      cash_flow.save!
    end

    render plain: 'true', status: :created
  end

  private

  def find_or_build_cash_flow(month, category_id)
    monthly_budget(month).cash_flows.find_by(category_id: category_id) ||
      monthly_budget(month).cash_flows.build(category_id: category_id)
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

  def monthly_budget(month)
    date = month
    @user.monthly_budgets.of_the_month(date).first ||
      @user.monthly_budgets.create!(month: date)
  end

  def all_months
    start_date = Date.parse(cash_flow_params[:from])
    end_date = Date.parse(cash_flow_params[:to])
    (start_date..end_date).to_a.group_by(&:month).values.map(&:first)
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
  def set_cash_flows
    @cash_flow = @monthly_budget.cash_flows.find_by(
      category_id: @category.id
    )
  end

  def cash_flow_params
    params[:cash_flow]
  end
end

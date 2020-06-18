class LoansController < ApplicationController
  before_action :set_user
  before_action :set_loan, only: %i[update]

  # GET /loans
  def index
    @loans = @user.loans.map do |l|
      l[:planned] = l.planned_cash_flow
      l[:actual] = l.actual_cash_flow
      l
    end

    render json: @loans
  end

  # POST /loans
  def create
    @loan = @user.loans.build(loan_params)

    if @loan.save
      @loan[:planned] = @loan.planned_cash_flow
      render json: @loan, status: :created
    else
      render json: @loan.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /loans/1
  def update
    if @loan.update(loan_params)
      render json: @loan
    else
      render json: @loan.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_loan
    @loan = @user.loans.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def loan_params
    params.require(:loan).permit(
      :description,
      :value,
      :emi,
      :start_date,
      :end_date
    )
  end
end

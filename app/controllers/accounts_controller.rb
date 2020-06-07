class AccountsController < ApplicationController
  before_action :set_user
  before_action :set_account, only: %i[update]

  # GET /accounts
  def index
    render json: @user.accounts
  end

  # POST /accounts
  def create
    @account = @user.accounts.build(account_params)

    if @account.save
      render json: @account, status: :created
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = @user.accounts.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(:name)
  end
end

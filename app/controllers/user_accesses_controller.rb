class UserAccessesController < ApplicationController
  before_action :set_user, :set_user_access

  # GET /user_accesses/1
  def show
    render json: @user_access.attributes.merge(
      referring_token: @user.referring_token,
      referred_users: @user_access.referred_users.count,
      referred_by: @user_access.referred_by_user.try(:email),
      completed_referred_users: @user_access.completed_referred_users.count
    )
  end

  def refer
    if @user_access.referred_by_user
      return render json: {
        message: ["cannot be referred by multiple people"]
      }, status: :bad_request
    end

    if @user_access.referred_by_code!(params[:referral_id])
      render json: { message: ["Success"] }, status: :accepted
    else
      render json: { message: ["Invalid referral code"] }, status: :bad_request
    end
  end

  def claim_plus_access
    if @user_access.claim_plus_access!
      render json: { message: "success" }, status: :accepted
    else
      render json: { message: ["Unable to process the request now."] },
             status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user_access
    @user_access = @user.user_access
  end
end

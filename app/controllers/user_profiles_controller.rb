class UserProfilesController < ApplicationController
  before_action :set_user, :set_user_profile, only: %i[show update]

  # GET /users/1/user_profiles
  def show
    render json: @user_profile
  end

  # PATCH/PUT /categories/1
  def update
    if @user_profile.update(user_profile_params)
      render json: @user_profile
    else
      render json: @user_profile.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_user_profile
    @user_profile = @user.user_profile
  end

  def user_profile_params
    params.require(:user_profile).permit(
      :first_name,
      :last_name,
      :dob,
      :gender,
      :monthly_income
    )
  end
end

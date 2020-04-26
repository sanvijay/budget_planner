class PersonalAdvisorRequestsController < ApplicationController
  skip_before_action :authenticate_user!

  # POST /personal_advisor_requests
  def create
    @par = PersonalAdvisorRequest.new(personal_advisor_request_params)

    if @par.save
      render json: @par, status: :created
    else
      render json: @par.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def personal_advisor_request_params
    params.require(:personal_advisor_request).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number
    )
  end
end

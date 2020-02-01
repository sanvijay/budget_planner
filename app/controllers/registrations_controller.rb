class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)

    if resource.save
      head :ok
    else
      render json: resource.errors, status: :bad_request
    end
  end
end

class PasswordsController < Devise::PasswordsController
  respond_to :json

  # POST /resource/password
  def create
    self.resource = resource_class
                    .send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      render json: resource
    else
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      respond_success_message(resource)
    else
      set_minimum_password_length
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  private

  def respond_success_message(resource)
    resource.unlock_access! if unlockable?(resource)
    if Devise.sign_in_after_reset_password
      resource.after_database_authentication
      sign_in(resource_name, resource)
    else
      set_flash_message!(:notice, :updated_not_active)
    end
    respond_with resource, location: after_resetting_password_path_for(resource)
  end
end

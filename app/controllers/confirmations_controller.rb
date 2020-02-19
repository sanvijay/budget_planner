class ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      redirect_to "#{APP_CONFIG['browser_base_url']}" \
        "#{APP_CONFIG['browser_confirmation_endpoint']}"
    else
      respond_with_navigational(
        resource.errors, status: :unprocessable_entity
      ) { render :new }
    end
  end
end

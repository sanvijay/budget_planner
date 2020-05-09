class SessionsController < Devise::SessionsController
  respond_to :json

  def create
    if params[:code]
      token = google_access_token

      unless token&.params && token.params["id_token"]
        return render(status: :unauthorized)
      end

      parsed_token = JWT.decode(token.params["id_token"], nil, false)
      return render(status: :unauthorized) unless parsed_token[0]["email"]

      unless (user = User.find_by(email: parsed_token[0]["email"]))
        user = User.new(email: parsed_token[0]["email"])
        user.skip_confirmation!
        user.save!(validate: false)
      end

      new_token = Warden::JWTAuth::TokenEncoder.new.call(sub: user._id.to_s, scp: "user")
      sign_in(:user, user)
      request.env['warden-jwt_auth.token'] = new_token

      render json: user
    else
      super
    end
  end

  private

  def current_token
    request.env['warden-jwt_auth.token']
  end

  def respond_with(resource, _opts = {})
    render json: resource
  end

  def respond_to_on_destroy
    head :ok
  end

  def google_access_token
    OAuth2::Client.new(
      google_oauth2[:client_id],
      google_oauth2[:client_secret],
      site: google_oauth2[:site],
      token_url: google_oauth2[:token_url],
      redirect_uri: APP_CONFIG['browser_base_url']
    ).auth_code.get_token(params[:code])
  rescue OAuth2::Error
    nil
  end

  def google_oauth2
    Rails.application.credentials[:google_oauth2]
  end
end

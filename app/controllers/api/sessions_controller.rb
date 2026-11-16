class Api::SessionsController < Api::BaseController
  skip_before_action :require_api_authentication, only: :create
  # Logging in / out is not about a record, so there is nothing to authorize
  skip_after_action :verify_authorized

  def create
    user = User.find_for_authentication(email: params[:email_address])
    unless user&.valid_password?(params[:password].to_s)
      return render json: { error: "Invalid email or password" }, status: :unauthorized
    end

    sign_in(user)
    render json: { user: user_json(user) }, status: :ok
  end

  def destroy
    sign_out(current_user)
    head :no_content
  end
end

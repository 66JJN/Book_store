class Api::SessionsController < Api::BaseController
  skip_before_action :require_api_authentication, only: :create

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))
    return render json: { error: "Invalid email or password" }, status: :unauthorized unless user

    session = user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
    cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    render json: { user: user_json(user) }, status: :ok
  end

  def destroy
    Current.session&.destroy
    Current.session = nil
    cookies.delete(:session_id)
    head :no_content
  end
end

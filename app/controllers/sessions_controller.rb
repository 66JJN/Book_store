class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new; end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user
      start_new_session_for(user)
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Invalid email or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Signed out successfully.", status: :see_other
  end
end

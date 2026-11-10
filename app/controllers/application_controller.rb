class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :admin?

  private

  def current_user
    Current.session&.user
  end

  def admin?
    current_user&.admin?
  end

  def require_admin
    redirect_to root_path, alert: "Admin access is required." unless admin?
  end
end

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Public on purpose: ActiveAdmin calls this from outside via
  # `config.on_unauthorized_access = :user_not_authorized`, which only works with public methods.
  # It is not an action anyone can visit, because no route points to it.
  def user_not_authorized(_exception = nil)
    redirect_back_or_to main_app.root_path, alert: "You are not authorized to perform this action."
  end
end
